import 'package:dart_api_query/src/qs/stringify_options.dart';
import 'package:dart_api_query/src/schema.dart';

final class PostWithOptions extends Schema {
  PostWithOptions(super.resourceObject);

  PostWithOptions.init() : super.init();

  @override
  StringifyOptions stringifyOptions() {
    return StringifyOptions(arrayFormat: ArrayFormat.indices);
  }
}
