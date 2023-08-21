import 'package:dart_api_query/src/schema.dart';

final class Comment extends Schema {
  Comment([super.attributes]);

  Comment.create(super.resourceObject) : super.create();

  Iterable<Comment>? get replies =>
      hasManyOrNull<Comment>('replies', Comment.create);
}
