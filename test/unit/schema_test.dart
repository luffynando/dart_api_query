import 'package:dart_api_query/src/api_query.dart';
import 'package:dart_api_query/src/resource_object.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

import '../dummy/data/post_embed_response.dart';
import '../dummy/data/post_response.dart';
import '../dummy/data/posts_response.dart';
import '../dummy/models/post.dart';
import '../dummy/models/tag.dart';
import '../dummy/models/user.dart';

void main() {
  group('Schema methods', () {
    late Dio dio;
    late DioAdapter dioAdapter;

    setUp(() {
      dio = Dio(BaseOptions());
      dioAdapter = DioAdapter(
        dio: dio,
      );

      ApiQuery.http = dio;
      ApiQuery.baseURL = 'http://localhost';
    });

    test(
      'first() returns first object in array as instance of such Schema',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            postsResponse,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = await ApiQuery.of(Post.new).first();
        expect(post.resourceObject, isA<ResourceObject>());
        expect(post.resourceObject.attributes, equals(postsResponse.first));
        expect(post, isA<Post>());
        expect(post.user, isA<User>());
        expect(post.id, equals(1));
        expect(post.someId, equals('du761-8bc98'));
        expect(post.text, equals('Lorem Ipsum Dolor'));
        expect(post.user!.fullname, equals('John Doe'));
        for (final tag in post.relationships['tags']!) {
          expect(tag, isA<Tag>());
        }
        expect(post.relationships['tags']!.first.name, equals('super'));
      },
    );

    test(
      'first() method throws StateError when no items have found',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            <dynamic>[],
            delay: const Duration(milliseconds: 500),
          ),
        );

        await expectLater(
          () => ApiQuery.of(Post.new).first(),
          throwsA(
            (dynamic e) => e is StateError && e.message.contains('No element'),
          ),
        );
      },
    );

    test(
      'firstOrNull() method returns null when no items have found',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            <dynamic>[],
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = await ApiQuery.of(Post.new).firstOrNull();
        expect(post, equals(null));
      },
    );

    test('find() method returns a object as instance of such Schema', () async {
      dioAdapter.onGet(
        'http://localhost/posts/1',
        (server) => server.reply(
          200,
          postResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final post = await ApiQuery.of(Post.new).find(1);
      expect(post.resourceObject.attributes, equals(postResponse));
      expect(post.resourceObject, isA<ResourceObject>());

      expect(post, isA<Post>());
      expect(post.id, equals(1));
      expect(post.someId, equals('af621-4aa41'));
      expect(post.text, equals('Lorem Ipsum Dolor'));
      expect(post.user!.fullname, equals('John Doe'));
      for (final tag in post.relationships['tags']!) {
        expect(tag, isA<Tag>());
      }
      expect(post.relationships['tags']!.first.name, equals('super'));
    });

    test('find() handles request with data wrapper', () async {
      dioAdapter.onGet(
        'http://localhost/posts/1',
        (server) => server.reply(
          200,
          postEmbedResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final post = await ApiQuery.of(Post.new).find(1);
      expect(post.resourceObject.attributes, equals(postEmbedResponse['data']));
      expect(post.resourceObject, isA<ResourceObject>());
      expect(post, isA<Post>());
      expect(post.id, equals(1));
      expect(post.someId, equals('af621-4aa41'));
      expect(post.text, equals('Lorem Ipsum Dolor'));
      expect(post.user!.fullname, equals('John Doe'));
      for (final tag in post.relationships['tags']!) {
        expect(tag, isA<Tag>());
      }
      expect(post.relationships['tags']!.first.name, equals('super'));
    });

    test(
      'find() return a obj as instance of such Schema with empty relationships',
      () async {
        final postResponseWithOutRelations = <String, dynamic>{}
          ..addAll(postResponse)
          ..addAll({
            'user': null
          })
          ..addAll({
            'relationships': {
              'tags': <Map<String, String>>[]
            }
          });

        dioAdapter.onGet(
          'http://localhost/posts/1',
          (server) => server.reply(
            200,
            postResponseWithOutRelations,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = await ApiQuery.of(Post.new).find(1);
        expect(
          post.resourceObject.attributes,
          equals(postResponseWithOutRelations),
        );
        expect(post, isA<Post>());
        expect(post.user, equals(null));
        expect(post.relationships['tags'], equals([]));
      },
    );

    test(
      'find() returns instance of such Schema with some empty relationship',
      () async {
        final postResponseWithSomeRelations = <String, dynamic>{}
          ..addAll(postResponse)
          ..addAll({
            'user': null
          });

        dioAdapter.onGet(
          'http://localhost/posts/1',
          (server) => server.reply(
            200,
            postResponseWithSomeRelations,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = await ApiQuery.of(Post.new).find(1);
        expect(
          post.resourceObject.attributes,
          equals(postResponseWithSomeRelations),
        );
        expect(post, isA<Post>());
        expect(post.user, equals(null));
        for (final tag in post.relationships['tags']!) {
          expect(tag, isA<Tag>());
        }
        expect(post.relationships['tags']!.first.name, equals('super'));
      },
    );

    test(
      'find() method throws StateError when no item have found',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts/1',
          (server) => server.reply(
            200,
            null,
            delay: const Duration(milliseconds: 500),
          ),
        );

        await expectLater(
          () => ApiQuery.of(Post.new).find(1),
          throwsA(
            (dynamic e) =>
                e is StateError &&
                e.message.contains('No response data or null.'),
          ),
        );
      },
    );

    test(
      'findOrNull() method returns null when no item have found',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts/1',
          (server) => server.reply(
            200,
            null,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = await ApiQuery.of(Post.new).findOrNull(1);
        expect(post, equals(null));
      },
    );
  });
}
