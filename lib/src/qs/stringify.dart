import 'package:dart_api_query/src/qs/stringify_options.dart';
import 'package:dart_api_query/src/qs/utils.dart';
import 'package:dart_api_query/src/side_channel/side_channel.dart';

Map<String, dynamic> _arrayPrefixGenerators = {
  ArrayFormat.brackets.name: (String prefix, dynamic key) {
    return '$prefix[]';
  },
  ArrayFormat.comma.name: 'comma',
  ArrayFormat.indices.name: (String prefix, dynamic key) {
    return '$prefix[$key]';
  },
  ArrayFormat.repeat.name: (String prefix, dynamic key) {
    return prefix;
  },
};

bool _isNonNullishPrimitive(dynamic v) {
  return v is String || v is int || v is double || v is BigInt || v is bool;
}

final _sentinel = <dynamic>{};

List<String> _stringify({
  required dynamic object,
  required String prefix,
  required dynamic generateArrayPrefix,
  required bool commaRoundTrip,
  required bool strictNullHandling,
  required bool skipNulls,
  required bool allowDots,
  required dynamic Function(DateTime) serializeDate,
  required RfcFormat format,
  required String Function(dynamic) formatter,
  required bool encodeValuesOnly,
  required Charset charset,
  required SideChannel sideChannel,
  dynamic Function(dynamic, Charset, RfcFormat)? encoder,
  int Function(dynamic, dynamic)? sort,
}) {
  var obj = object;

  dynamic tmpSc = sideChannel;
  var step = 0;
  var findFlag = false;
  while ((tmpSc = tmpSc is SideChannel ? tmpSc.get(_sentinel) : null) != null &&
      !findFlag) {
    // Where object last appeared in the ref tree
    final pos = tmpSc is SideChannel ? tmpSc.get(object) : null;
    step += 1;
    if (pos != null) {
      if (pos == step) {
        throw RangeError('Cyclic object value');
      } else {
        findFlag = true; // Break while
      }
    }

    if ((tmpSc is SideChannel ? tmpSc.get(_sentinel) : null) != null) {
      step = 0;
    }
  }

  if (obj is DateTime) {
    obj = serializeDate(obj);
  } else if (generateArrayPrefix == 'comma' && obj is List) {
    obj = Utils.maybeMap(obj,
        (dynamic value, Charset? charset, RfcFormat? rfcFormat) {
      if (value is DateTime) {
        return serializeDate(value);
      }

      return value;
    });
  }

  if (obj == null) {
    if (strictNullHandling) {
      if (encoder != null && !encodeValuesOnly) {
        return [encoder(prefix, charset, format) as String];
      } else {
        return [prefix];
      }
    }

    obj = '';
  }

  if (_isNonNullishPrimitive(obj) || obj is StringBuffer) {
    if (encoder != null) {
      final keyValue =
          encodeValuesOnly ? prefix : encoder(prefix, charset, format);
      return [
        '${formatter(keyValue)}=${formatter(
          encoder(
            obj,
            charset,
            format,
          ),
        )}'
      ];
    }

    return ['${formatter(prefix)}=${formatter(obj)}'];
  }

  final values = <String>[];
  if (obj == null) {
    return <String>[];
  }

  var objKeys = <dynamic>[];
  if (generateArrayPrefix == 'comma' && obj is List) {
    if (encodeValuesOnly && encoder != null) {
      obj = Utils.maybeMap(
        obj,
        encoder as dynamic Function(dynamic, Charset?, RfcFormat?),
      );
    }

    if (obj is List && obj.isNotEmpty) {
      final countAll = obj.length;
      final countNulls = obj.where((element) => element == null).length;
      objKeys = [
        {
          'value': countAll != countNulls
              ? obj.map((element) => element ?? '').toList().join(',')
              : null,
        }
      ];
    } else {
      objKeys = [];
    }
  } else if (obj is List) {
    final keys = obj.asMap().keys.toList();
    if (sort != null) {
      keys.sort(sort);
    }

    objKeys = keys;
  } else if (obj is Map) {
    final keys = obj.keys.toList();
    if (sort != null) {
      keys.sort(sort);
    }

    objKeys = keys;
  } else {
    return values;
  }

  final adjustedPrefix =
      commaRoundTrip && obj is List && obj.length == 1 ? '$prefix[]' : prefix;

  for (var j = 0; j < objKeys.length; ++j) {
    final key = objKeys.elementAt(j);
    final value = key is Map && key.containsKey('value')
        ? key['value']
        : obj is List
            ? obj.elementAt(key as int)
            : (obj as Map)[key];

    if (skipNulls && value == null) {
      continue;
    }

    final keyPrefix = obj is List
        ? generateArrayPrefix != 'comma'
            ? (generateArrayPrefix as String Function(String, dynamic))(
                adjustedPrefix,
                key,
              )
            : adjustedPrefix
        : '$adjustedPrefix${allowDots ? '.$key' : '[$key]'}';

    sideChannel.set(object, step);
    final valueSideChannel = SideChannel()..set(_sentinel, sideChannel);
    values.addAll(
      _stringify(
        object: value,
        prefix: keyPrefix,
        generateArrayPrefix: generateArrayPrefix,
        commaRoundTrip: commaRoundTrip,
        strictNullHandling: strictNullHandling,
        skipNulls: skipNulls,
        encoder:
            generateArrayPrefix == 'comma' && encodeValuesOnly && obj is List
                ? null
                : encoder,
        sort: sort,
        allowDots: allowDots,
        serializeDate: serializeDate,
        format: format,
        formatter: formatter,
        encodeValuesOnly: encodeValuesOnly,
        charset: charset,
        sideChannel: valueSideChannel,
      ),
    );
  }

  return values;
}

/// Stringify object with some added security
String stringifyUtility(
  dynamic object, {
  StringifyOptions? opts,
}) {
  if (object == null || (object is! Map && object is! List)) {
    return '';
  }

  Map<dynamic, dynamic> obj;
  if (object is List) {
    obj = {for (final e in object) object.indexOf(e).toString(): e};
  } else {
    obj = object as Map<dynamic, dynamic>;
  }

  final options = StringifyOptions.normalize(opts);
  ArrayFormat? arrayFormat;
  if (opts != null &&
      opts.arrayFormat != null &&
      _arrayPrefixGenerators.containsKey(opts.arrayFormat!.name)) {
    arrayFormat = opts.arrayFormat;
  } else if (opts != null && opts.indices != null) {
    arrayFormat = opts.indices! ? ArrayFormat.indices : ArrayFormat.repeat;
  } else {
    arrayFormat = ArrayFormat.indices;
  }

  final generateArrayPrefix = _arrayPrefixGenerators[arrayFormat!.name];
  final commaRoundTrip = generateArrayPrefix == 'comma' &&
      opts != null &&
      opts.commaRoundTrip != null &&
      opts.commaRoundTrip!;
  final objKeys = obj.keys.toList();

  if (options.sort != null) {
    objKeys.sort(options.sort);
  }

  final keys = <String>[];
  final sideChannel = SideChannel();
  for (var i = 0; i < objKeys.length; i++) {
    final key = objKeys.elementAt(i);

    if (options.skipNulls! && obj[key] == null) {
      continue;
    }

    keys.addAll(
      _stringify(
        object: obj[key],
        prefix: '$key',
        generateArrayPrefix: generateArrayPrefix,
        commaRoundTrip: commaRoundTrip,
        strictNullHandling: options.strictNullHandling!,
        skipNulls: options.skipNulls!,
        encoder: options.encode! ? options.encoder! : null,
        sort: options.sort,
        allowDots: options.allowDots!,
        serializeDate: options.serializeDate!,
        format: options.format!,
        formatter: options.formatter!,
        encodeValuesOnly: options.encodeValuesOnly!,
        charset: options.charset!,
        sideChannel: sideChannel,
      ),
    );
  }

  final joined = keys.join(options.delimiter!);
  var prefix = true == options.addQueryPrefix ? '?' : '';

  if (options.charsetSentinel!) {
    if (options.charset == Charset.iso88591) {
      prefix += 'utf8=%26%2310003%3B&';
    } else {
      prefix += 'utf8=%E2%9C%93&';
    }
  }

  return joined.isNotEmpty ? '$prefix$joined' : '';
}
