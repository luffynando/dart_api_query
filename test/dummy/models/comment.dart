import 'package:dart_api_query/src/schema.dart';

final class Comment extends Schema {
  Comment(super.resourceObject);

  Comment.init() : super.init();

  Iterable<Comment>? get replies =>
      hasManyOrNull<Comment>('replies', Comment.new);
}
