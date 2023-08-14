import 'package:dart_api_query/src/schema.dart';

final class Tag extends Schema {
  Tag(super.resourceObject);

  Tag.init() : super.init();

  String get name => getAttribute<String>('name');
}
