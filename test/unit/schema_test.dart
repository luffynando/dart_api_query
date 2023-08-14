import 'package:dart_api_query/src/api_query.dart';
import 'package:dart_api_query/src/resource_object.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

import '../dummy/data/post_response.dart';
import '../dummy/data/posts_response.dart';
import '../dummy/models/post.dart';
import '../dummy/models/tag.dart';
import '../dummy/models/user.dart';

void main() {
  group('Schema methods', () {
    final dio = Dio(BaseOptions());
    final dioAdapter = DioAdapter(dio: dio);

    setUp(() {
      ApiQuery.http = dio;
      ApiQuery.baseURL = 'http://localhost';
    });

    test(
      'first() returns first object in array as instance of resource object',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            postsResponse,
            delay: const Duration(seconds: 1),
          ),
        );

        final resourceObject = await ApiQuery.of(Post.init()).first();
        expect(resourceObject!.attributes, equals(postsResponse[0]));
        expect(resourceObject, isA<ResourceObject>());

        final post = Post(resourceObject);
        expect(post, isA<Post>());
        expect(post.user, isA<User>());
        expect(post.id, equals(1));
        expect(post.someId, equals('du761-8bc98'));
        expect(post.text, equals('Lorem Ipsum Dolor'));
        expect(post.user!.fullname, equals('John Doe'));
        for (final tag in post.relationships['tags']!) {
          expect(tag, isA<Tag>());
        }
        expect(post.relationships['tags']![0].name, equals('super'));
      },
    );

    test(
      'first() method returns null when no items have found',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            <dynamic>[],
            delay: const Duration(seconds: 1),
          ),
        );

        final resourceObject = await ApiQuery.of(Post.init()).first();
        expect(resourceObject, equals(null));
      },
    );

    test('find() method returns a resource object', () async {
      dioAdapter.onGet(
        'http://localhost/posts/1',
        (server) => server.reply(
          200,
          postResponse,
          delay: const Duration(seconds: 1),
        ),
      );

      final objectResource = await ApiQuery.of(Post.init()).find(1);
      expect(objectResource.attributes, equals(postResponse));
      expect(objectResource, isA<ResourceObject>());

      final post = Post(objectResource);
      expect(post, isA<Post>());
      expect(post.user, isA<User>());
      for (final tag in post.relationships['tags']!) {
        expect(tag, isA<Tag>());
      }
    });

    test(
      'find() method return a obj as instance of Model with empty relationship',
      () async {
        final overridePostResponse = postResponse;
        overridePostResponse['user'] = null;
        (overridePostResponse['relationships']
                as Map<String, List<Map<String, String>>>)['tags'] =
            <Map<String, String>>[];

        dioAdapter.onGet(
          'http://localhost/posts/1',
          (server) => server.reply(
            200,
            overridePostResponse,
            delay: const Duration(seconds: 1),
          ),
        );

        final objectResource = await ApiQuery.of(Post.init()).find(1);
        expect(objectResource.attributes, equals(postResponse));
        expect(objectResource, isA<ResourceObject>());

        final post = Post(objectResource);
        expect(post, isA<Post>());
        expect(post.user, equals(null));
        expect(post.relationships['tags'], equals([]));
      },
    );
  });
}
