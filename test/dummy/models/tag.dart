import 'package:dart_api_query/src/schema.dart';

final class Tag extends Schema {
  Tag([super.attributes]);

  Tag.create(super.resourceObject) : super.create();

  String get name => getAttribute<String>('name');
}
