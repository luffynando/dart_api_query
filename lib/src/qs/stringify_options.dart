import 'package:dart_api_query/src/qs/utils.dart';

/// How to parse array format to use on stringify function
enum ArrayFormat {
  /// Array format indices
  indices,

  /// Array format brackets
  brackets,

  /// Array format repeat
  repeat,

  /// Array format comma
  comma,
}

/// Rfc format to use on stringify function
enum RfcFormat {
  /// RFC-1738 format
  rfc1738,

  /// RFC-3986 format
  rfc3986,
}

/// Charset type to use on stringify function
enum Charset {
  /// UTF-8 Charset
  utf8,

  /// ISO-8859-1 Charset
  iso88591,
}

/// Stringify options for handle stringify
class StringifyOptions {
  /// Constructor with optional parameters
  StringifyOptions({
    this.delimiter,
    this.strictNullHandling,
    this.skipNulls,
    this.encode,
    this.encoder,
    this.arrayFormat,
    this.commaRoundTrip,
    this.indices,
    this.sort,
    this.serializeDate,
    this.format,
    this.formatter,
    this.encodeValuesOnly,
    this.addQueryPrefix,
    this.allowDots,
    this.charset,
    this.charsetSentinel,
  });

  /// Get default stringify options
  factory StringifyOptions.fromDefaults() {
    return StringifyOptions(
      addQueryPrefix: false,
      allowDots: false,
      charset: Charset.utf8,
      charsetSentinel: false,
      delimiter: '&',
      encode: true,
      encoder: Utils.encode,
      encodeValuesOnly: false,
      format: RfcFormat.rfc3986,
      formatter: (dynamic value) {
        return '$value';
      },
      indices: false,
      serializeDate: (DateTime date) {
        return date.toIso8601String();
      },
      skipNulls: false,
      strictNullHandling: false,
    );
  }

  /// Normalize stringify options if optional variable not is included
  factory StringifyOptions.normalize(StringifyOptions? opts) {
    if (opts == null) {
      return StringifyOptions.fromDefaults();
    }

    final charset = opts.charset ?? Charset.utf8;
    var format = RfcFormat.rfc3986;
    if (opts.format != null) {
      format = opts.format!;
    }

    String formatter(dynamic value) {
      return format == RfcFormat.rfc3986
          ? '$value'
          : '$value'.replaceAll(RegExp('%20'), '+');
    }

    return StringifyOptions(
      addQueryPrefix: opts.addQueryPrefix ?? false,
      allowDots: opts.allowDots ?? false,
      charset: charset,
      charsetSentinel: opts.charsetSentinel ?? false,
      delimiter: opts.delimiter ?? '&',
      encode: opts.encode ?? true,
      encoder: opts.encoder ?? Utils.encode,
      encodeValuesOnly: opts.encodeValuesOnly ?? false,
      format: format,
      formatter: formatter,
      serializeDate: opts.serializeDate ??
          (DateTime date) {
            return date.toIso8601String();
          },
      skipNulls: opts.skipNulls ?? false,
      sort: opts.sort,
      strictNullHandling: opts.strictNullHandling ?? false,
    );
  }

  /// Merge Current StringifyOptions with override values
  StringifyOptions merge(StringifyOptions opts) {
    return StringifyOptions(
      arrayFormat: opts.arrayFormat ?? arrayFormat,
      commaRoundTrip: opts.commaRoundTrip ?? commaRoundTrip,
      indices: opts.indices ?? indices,
      addQueryPrefix: opts.addQueryPrefix ?? addQueryPrefix,
      allowDots: opts.allowDots ?? allowDots,
      charset: opts.charset ?? charset,
      charsetSentinel: opts.charsetSentinel ?? charsetSentinel,
      delimiter: opts.delimiter ?? delimiter,
      encode: opts.encode ?? encode,
      encoder: opts.encoder ?? encoder,
      encodeValuesOnly: opts.encodeValuesOnly ?? encodeValuesOnly,
      format: opts.format ?? format,
      formatter: opts.formatter ?? formatter,
      serializeDate: opts.serializeDate ?? serializeDate,
      skipNulls: opts.skipNulls ?? skipNulls,
      sort: opts.sort ?? sort,
      strictNullHandling: opts.strictNullHandling ?? strictNullHandling,
    );
  }

  /// Delimiter
  String? delimiter;

  /// Strict null handling
  bool? strictNullHandling;

  /// Skip nulls
  bool? skipNulls;

  /// Encode query
  bool? encode;

  /// Function to use to encoder string
  dynamic Function(dynamic, Charset?, RfcFormat?)? encoder;

  /// Format array to use
  ArrayFormat? arrayFormat;

  /// CommaRoundTrip
  bool? commaRoundTrip;

  /// With indices
  bool? indices;

  /// Function to sort
  int Function(dynamic, dynamic)? sort;

  /// Function to convert datetime
  dynamic Function(DateTime)? serializeDate;

  /// Rfc format to use
  RfcFormat? format;

  /// Function to use based on rfc format
  String Function(dynamic)? formatter;

  /// Encode values only
  bool? encodeValuesOnly;

  /// Add query prefix
  bool? addQueryPrefix;

  /// Allow dots
  bool? allowDots;

  /// Charset to use
  Charset? charset;

  /// With charset sentinel
  bool? charsetSentinel;
}
