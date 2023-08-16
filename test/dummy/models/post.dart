import 'package:dart_api_query/src/schema.dart';

import 'tag.dart';
import 'user.dart';

final class Post extends Schema {
  Post(super.resourceObject);

  Post.init() : super.init();

  String get text => getAttribute<String>('text');

  String get someId => getAttribute<String>('someId');

  User? get user => hasOneOrNull('user', User.new);

  Map<String, Iterable<Tag>> get relationships {
    return {'tags': hasManyOrNull('relationships.tags', Tag.new) ?? []};
  }
}
