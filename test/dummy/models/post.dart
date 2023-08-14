import 'package:dart_api_query/src/schema.dart';

import 'tag.dart';
import 'user.dart';

final class Post extends Schema {
  Post(super.resourceObject);

  Post.init() : super.init();

  String get text => getAttribute<String>('text');

  String get someId => getAttribute<String>('someId');

  User? get user => User(deserializeOne(dataForHasOne('user')));

  Map<String, List<Tag>> get relationships => {
        'tags': (getAttribute<Map<String, dynamic>>('relationships')['tags']
                as List<dynamic>)
            .map((data) => Tag(deserializeOne(data as Map<String, dynamic>)))
            .toList()
      };
}
