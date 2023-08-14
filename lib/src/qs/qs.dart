import 'package:dart_api_query/src/qs/stringify.dart';
import 'package:dart_api_query/src/qs/stringify_options.dart';

/// Query Stringify Class
class Qs {
  Qs._();

  /// Stringify object with some added security
  static String Function(dynamic, {StringifyOptions? opts}) stringify =
      stringifyUtility;
}
