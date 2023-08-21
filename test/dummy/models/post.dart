import 'package:dart_api_query/src/api_query.dart';
import 'package:dart_api_query/src/schema.dart';

import 'comment.dart';
import 'tag.dart';
import 'user.dart';

final class Post extends Schema {
  Post([super.attributes]);

  Post.create(super.resourceObject) : super.create();

  static String customKey = 'id';

  @override
  String primaryKey() {
    return Post.customKey;
  }

  String get text => getAttribute<String>('text');

  set text(String value) => setAttribute<String>('text', value);

  String get someId => getAttribute<String>('someId');

  User? get user => hasOneOrNull('user', User.create);

  ApiQuery<Comment> comments() {
    return load(Comment.create);
  }

  Map<String, Iterable<Tag>> get relationships {
    return {'tags': hasManyOrNull('relationships.tags', Tag.create) ?? []};
  }
}
