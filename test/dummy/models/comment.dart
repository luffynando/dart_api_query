import 'package:dart_api_query/src/schema.dart';

final class Comment extends Schema {
  Comment(super.resourceObject);

  Comment.init() : super.init();

  Iterable<Comment>? get replies => dataForHasMany('replies')
      ?.map((data) => deserializeOne(data as Map<String, dynamic>))
      .map(Comment.new);
}
