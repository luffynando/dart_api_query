import 'package:dart_api_query/src/qs/stringify_options.dart';

/// List of chars on hex
List<String> _hexTable = List.generate(
  256,
  (i) => '%${i < 16 ? '0' : ''}${i.toRadixString(16).toUpperCase()}',
);

String _hex(int code, int length) {
  final result = code.toRadixString(16);
  return result.padLeft(length, '0');
}

String _escape(String str) {
  final result = StringBuffer();
  final length = str.length;
  final ascii = RegExp(r'^[\x00-\x7F]+$');
  var index = 0;
  while (index < length) {
    final chr = str.substring(index, 1);
    if (ascii.hasMatch(chr)) {
      result.write(chr);
    } else {
      final code = chr.codeUnitAt(0);
      if (code < 256) {
        result.write('%${_hex(code, 2).toUpperCase()}');
      } else {
        result.write('%u${_hex(code, 4).toUpperCase()}');
      }
    }
    index++;
  }

  return result.toString();
}

/// Encode a string in specific format
String _encode(
  dynamic value,
  Charset? charset,
  RfcFormat? format,
) {
  final str = value.toString();

  if (str.isEmpty) {
    return str;
  }

  final string = str;
  if (charset == Charset.iso88591) {
    return _escape(str).replaceAllMapped(
      RegExp(
        '%u[0-9a-f]{4}',
        caseSensitive: false,
      ),
      (match) => '%26%23${int.parse(match[0]!.substring(2), radix: 16)}%3B',
    );
  }

  final out = StringBuffer();
  for (var i = 0; i < string.length; ++i) {
    var c = string.codeUnitAt(i);

    if (c == 0x2D || // -
        c == 0x2E || // .
        c == 0x5F || // _
        c == 0x7E || // ~
        (c >= 0x30 && c <= 0x39) ||
        (c >= 0x41 && c <= 0x5A) ||
        (c >= 0x61 && c <= 0x7A) ||
        (format == RfcFormat.rfc1738 && (c == 0x28 || c == 0x29))) {
      out.write(string[i]);
      continue;
    }

    if (c < 0x80) {
      out.write(_hexTable[c]);
      continue;
    }

    if (c < 0x800) {
      out.write('${_hexTable[0xC0 | (c >> 6)]}${_hexTable[0x80 | (c & 0x3F)]}');
      continue;
    }

    if (c < 0xD800 || c >= 0xE000) {
      out
        ..write(_hexTable[0xE0 | (c >> 12)])
        ..write(_hexTable[0x80 | ((c >> 6) & 0x3F)])
        ..write(_hexTable[0x80 | (c & 0x3F)]);
      continue;
    }

    i += 1;
    c = 0x10000 + (((c & 0x3FF) << 10) | (string.codeUnitAt(i) & 0x3FF));

    out
      ..write(_hexTable[0xF0 | (c >> 18)])
      ..write(_hexTable[0x80 | ((c >> 12) & 0x3F)])
      ..write(_hexTable[0x80 | ((c >> 6) & 0x3F)])
      ..write(_hexTable[0x80 | (c & 0x3F)]);
  }

  return out.toString();
}

/// Utils helper class
class Utils {
  Utils._();

  /// Function to encode string
  static dynamic Function(
    dynamic str,
    Charset? charset,
    RfcFormat? format,
  ) encode = _encode;

  /// Function to retrieve List<dynamic>
  static dynamic maybeMap(
    dynamic val,
    dynamic Function(
      dynamic,
      Charset?,
      RfcFormat?,
    ) fn,
  ) {
    if (val is List) {
      final mapped = <dynamic>[];
      for (var i = 0; i < val.length; i += 1) {
        final tempValue = val.elementAt(i);
        mapped.add(fn(tempValue, null, null));
      }

      return mapped;
    }

    return fn(val, null, null);
  }
}
