import 'package:dart_api_query/src/api_query.dart';
import 'package:dart_api_query/src/schema.dart';

import 'post.dart';

final class User extends Schema {
  User([super.attributes]);

  User.create(super.objectResource) : super.create();

  String get firstname => getAttribute<String>('firstname');

  String get lastname => getAttribute<String>('lastname');

  String get fullname => '$firstname $lastname';

  ApiQuery<Post> posts({Post? current}) {
    return load(Post.create, current: current);
  }
}
