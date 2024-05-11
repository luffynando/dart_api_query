import 'package:dart_api_query/src/schema.dart';
import 'package:qs_dart/qs_dart.dart';

final class PostWithOptions extends Schema {
  PostWithOptions([super.attributes]);

  PostWithOptions.create(super.resourceObject) : super.create();

  @override
  EncodeOptions stringifyOptions() =>
      const EncodeOptions(listFormat: ListFormat.indices);
}
