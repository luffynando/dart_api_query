import 'dart:convert';
import 'package:dart_api_query/dart_api_query.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

import '../dummy/data/comments_embed_response.dart';
import '../dummy/data/comments_response.dart';
import '../dummy/data/post_embed_response.dart';
import '../dummy/data/post_response.dart';
import '../dummy/data/posts_response.dart';
import '../dummy/data/posts_response_paginate.dart';
import '../dummy/models/comment.dart';
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
      Post.customKey = 'id';
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

        final post = await ApiQuery.of(Post.create).first();
        expect(post.resourceObject, isA<ResourceObject>());
        expect(post.attributes, equals(postsResponse.first));
        expect(post, isA<Post>());
        expect(post.user, isA<User>());
        expect(post.id, equals(1));
        expect(post.someId, equals('du761-8bc98'));
        expect(post.text, equals('Lorem Ipsum Dolor'));
        expect(post.user!.fullname, equals('John Doe'));
        expect(post.relationships['tags'], everyElement(isA<Tag>()));
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
          () => ApiQuery.of(Post.create).first(),
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

        final post = await ApiQuery.of(Post.create).firstOrNull();
        expect(post, isNull);
      },
    );

    test(
      'firstOrNull() method returns null when unauthorized',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts',
          (server) => server.reply(
            401,
            <dynamic>[],
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = await ApiQuery.of(Post.create).firstOrNull();
        expect(post, isNull);
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

      final post = await ApiQuery.of(Post.create).find(1);
      expect(post.attributes, equals(postResponse));
      expect(post.resourceObject, isA<ResourceObject>());

      expect(post, isA<Post>());
      expect(post.id, equals(1));
      expect(post.someId, equals('af621-4aa41'));
      expect(post.text, equals('Lorem Ipsum Dolor'));
      expect(post.user!.fullname, equals('John Doe'));
      expect(post.relationships['tags'], everyElement(isA<Tag>()));
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

      final post = await ApiQuery.of(Post.create).find(1);
      expect(post.attributes, equals(postEmbedResponse['data']));
      expect(post.resourceObject, isA<ResourceObject>());
      expect(post, isA<Post>());
      expect(post.id, equals(1));
      expect(post.someId, equals('af621-4aa41'));
      expect(post.text, equals('Lorem Ipsum Dolor'));
      expect(post.user!.fullname, equals('John Doe'));
      expect(post.relationships['tags'], everyElement(isA<Tag>()));
      expect(post.relationships['tags']!.first.name, equals('super'));
    });

    test(
      'find() return a obj as instance of such Schema with empty relationships',
      () async {
        final postResponseWithOutRelations = <String, dynamic>{}
          ..addAll(
            postResponse,
          )
          ..addAll({'user': null})
          ..addAll({
            'relationships': {'tags': <Map<String, String>>[]},
          });

        dioAdapter.onGet(
          'http://localhost/posts/1',
          (server) => server.reply(
            200,
            postResponseWithOutRelations,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = await ApiQuery.of(Post.create).find(1);
        expect(
          post.attributes,
          equals(postResponseWithOutRelations),
        );
        expect(post, isA<Post>());
        expect(post.user, isNull);
        expect(post.relationships['tags'], isEmpty);
      },
    );

    test(
      'find() returns instance of such Schema with some empty relationship',
      () async {
        final postResponseWithSomeRelations = <String, dynamic>{}
          ..addAll(
            postResponse,
          )
          ..addAll({'user': null});

        dioAdapter.onGet(
          'http://localhost/posts/1',
          (server) => server.reply(
            200,
            postResponseWithSomeRelations,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = await ApiQuery.of(Post.create).find(1);
        expect(
          post.attributes,
          equals(postResponseWithSomeRelations),
        );
        expect(post, isA<Post>());
        expect(post.user, isNull);
        expect(post.relationships['tags'], everyElement(isA<Tag>()));
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
          () => ApiQuery.of(Post.create).find(1),
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

        final post = await ApiQuery.of(Post.create).findOrNull(1);
        expect(post, isNull);
      },
    );

    test(
      'get() method returns a array of objects as instance of suchSchema',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            postsResponse,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final posts = await ApiQuery.of(Post.create).get();
        expect(posts, isNotEmpty);

        for (final post in posts) {
          expect(post, isA<Post>());
          expect(post.user, isA<User>());
          expect(post.relationships['tags'], everyElement(isA<Tag>()));
        }
      },
    );

    test('get() hits right resource (nested object)', () async {
      dioAdapter.onGet(
        'http://localhost/posts/1/comments',
        (server) => server.reply(
          200,
          commentsResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final post = Post({'id': 1});
      final comments = await post.comments().get();

      expect(comments, isNotEmpty);
      expect(comments, everyElement(isA<Comment>()));
      for (final comment in comments) {
        expect(comment.replies, isNotEmpty);
        expect(comment.replies, everyElement(isA<Comment>()));
      }
    });

    test('get() hits right resource (nested object, custom PK)', () async {
      Post.customKey = 'someId';

      dioAdapter.onGet(
        'http://localhost/posts/po9996-9dd18/comments',
        (server) => server.reply(
          200,
          commentsResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );
      final post = Post({'id': 1, 'someId': 'po9996-9dd18'});
      final comments = await post.comments().get();

      expect(comments, isNotEmpty);
      expect(comments, everyElement(isA<Comment>()));
      for (final comment in comments) {
        expect(comment.replies, isNotEmpty);
        expect(comment.replies, everyElement(isA<Comment>()));
      }
    });

    test('get() fetch style request with data wrapper', () async {
      dioAdapter.onGet(
        'http://localhost/posts',
        (server) => server.reply(
          200,
          postEmbedResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final posts = await ApiQuery.of(Post.create).get();
      expect(posts, isNotEmpty);
      expect(posts.first.attributes, equals(postEmbedResponse['data']));
    });

    test('get() fetch style request without data wrapper', () async {
      dioAdapter.onGet(
        'http://localhost/posts',
        (server) => server.reply(
          200,
          postEmbedResponse['data'],
          delay: const Duration(milliseconds: 500),
        ),
      );

      final posts = await ApiQuery.of(Post.create).get();
      expect(posts, isNotEmpty);
      expect(posts.first.attributes, equals(postEmbedResponse['data']));
    });

    test(
      'get() hits right resource with data wrapper (nested object)',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts/1/comments',
          (server) => server.reply(
            200,
            commentsEmbedResponse,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = Post({'id': 1});
        final comments = await post.comments().get();

        expect(comments, isNotEmpty);
        expect(comments, everyElement(isA<Comment>()));
        for (final comment in comments) {
          expect(comment.replies, isNotEmpty);
          expect(comment.replies, everyElement(isA<Comment>()));
        }
      },
    );

    test('all() method should be an alias of get() method', () async {
      dioAdapter.onGet(
        'http://localhost/posts',
        (server) => server.reply(
          200,
          postsResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final postsAll = await ApiQuery.of(Post.create).all();
      final postsGet = await ApiQuery.of(Post.create).get();

      expect(
        postsAll.toList().map((e) => e.attributes),
        equals(postsGet.toList().map((e) => e.attributes)),
      );
    });

    test(
      'save() method makes a POST request when ID of object does not exists',
      () async {
        final postSaveResponse = {
          'id': 1,
          'text': 'Cool!',
          'user': {'firstname': 'John', 'lastname': 'Doe', 'age': 25},
          'relationships': {
            'tags': [
              {'name': 'super'},
              {'name': 'awesome'},
            ],
          },
        };

        dioAdapter.onPost(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            postSaveResponse,
            delay: const Duration(milliseconds: 500),
          ),
          data: jsonEncode({'text': 'Cool!'}),
        );

        var post = Post()..text = 'Cool!';
        post = await ApiQuery.of(Post.create, current: post).save();

        expect(post.attributes, equals(postSaveResponse));
        expect(post, isA<Post>());
        expect(post.user, isA<User>());
        expect(post.relationships['tags'], everyElement(isA<Tag>()));
      },
    );

    test(
      'save() method makes a PUT request when ID of object exists',
      () async {
        dioAdapter
          ..onGet(
            'http://localhost/posts/1',
            (server) => server.reply(
              200,
              postResponse,
              delay: const Duration(milliseconds: 500),
            ),
          )
          ..onPut(
            'http://localhost/posts/1',
            (server) => server.reply(
              200,
              {
                'id': 1,
                'text': 'Cool!',
                'user': {'firstname': 'John', 'lastname': 'Doe', 'age': 25},
                'relationships': {
                  'tags': [
                    {'name': 'super'},
                    {'name': 'awesome'},
                  ],
                },
              },
              delay: const Duration(milliseconds: 500),
            ),
            data: jsonEncode(
              {}
                ..addAll(postResponse)
                ..addAll({'text': 'Cool!'}),
            ),
          );

        var post = await ApiQuery.of(Post.create).find(1);
        expect(post.text, equals('Lorem Ipsum Dolor'));

        post.text = 'Cool!';
        post = await ApiQuery.of(Post.create, current: post).save();
        expect(post.text, equals('Cool!'));
      },
    );

    test(
      'save() method makes a PUT request when ID of object exists (custom PK)',
      () async {
        Post.customKey = 'someId';

        var post = Post({'id': 1, 'someId': 'xs911-8cf12', 'text': 'Cool!'});

        dioAdapter.onPut(
          'http://localhost/posts/${post.someId}',
          (server) => server.reply(
            200,
            {
              'id': 1,
              'text': 'Cool!',
              'someId': 'xs911-8cf12',
              'user': {'firstname': 'John', 'lastname': 'Doe', 'age': 25},
              'relationships': {
                'tags': [
                  {'name': 'super'},
                  {'name': 'awesome'},
                ],
              },
            },
            delay: const Duration(milliseconds: 500),
          ),
          data: jsonEncode(
            {}..addAll(post.attributes),
          ),
        );

        expect(post.user, isNull);

        post = await ApiQuery.of(Post.create, current: post).save();
        expect(post.text, equals('Cool!'));
        expect(post.user, isNotNull);
      },
    );

    test(
      'save() method makes a PUT req when ID of object exists (nested object)',
      () async {
        dioAdapter
          ..onGet(
            'http://localhost/posts/1/comments',
            (server) => server.reply(200, commentsResponse),
          )
          ..onPut(
            'http://localhost/posts/1/comments/1',
            (server) => server.reply(
              200,
              <String, dynamic>{}
                ..addAll(commentsResponse.first)
                ..addAll({'text': 'Owh!'}),
            ),
            data: jsonEncode(
              {}
                ..addAll(commentsResponse.first)
                ..addAll({'text': 'Owh!'}),
            ),
          );

        final post = Post({'id': 1});
        var comment = await post.comments().first();
        expect(comment.text, equals('Hello'));

        comment.text = 'Owh!';
        comment = await post.comments(current: comment).save();
        expect(comment.text, 'Owh!');
      },
    );

    test(
      'save() makes a PUT req when ID of obj exists (nested obj, custom PK)',
      () async {
        Post.customKey = 'someId';

        final post = Post({'id': 1, 'someId': 'xs911-8cf12', 'title': 'Cool!'});

        dioAdapter
          ..onGet(
            'http://localhost/posts/${post.someId}/comments',
            (server) => server.reply(200, commentsResponse),
          )
          ..onPut(
            'http://localhost/posts/${post.someId}/comments/1',
            (server) => server.reply(
              200,
              <String, dynamic>{}
                ..addAll(commentsResponse.first)
                ..addAll({'text': 'Owh!'}),
            ),
            data: jsonEncode(
              {}
                ..addAll(commentsResponse.first)
                ..addAll({'text': 'Owh!'}),
            ),
          );

        var comment = await post.comments().first();
        expect(comment.text, equals('Hello'));

        comment.text = 'Owh!';
        comment = await post.comments(current: comment).save();
        expect(comment.text, 'Owh!');
      },
    );

    test(
      'save() method makes a POST request when ID of object is null',
      () async {
        final postSaveResponse = {
          'id': 1,
          'text': 'Cool!',
          'user': {'firstname': 'John', 'lastname': 'Doe', 'age': 25},
          'relationships': {
            'tags': [
              {'name': 'super'},
              {'name': 'awesome'},
            ],
          },
        };

        dioAdapter.onPost(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            postSaveResponse,
            delay: const Duration(milliseconds: 500),
          ),
          data: jsonEncode({'id': null, 'text': 'Cool!'}),
        );

        var post = Post({'id': null, 'text': 'Cool!'});
        post = await ApiQuery.of(Post.create, current: post).save();

        expect(post.attributes, equals(postSaveResponse));
        expect(post, isA<Post>());
        expect(post.user, isA<User>());
        expect(post.relationships['tags'], everyElement(isA<Tag>()));
      },
    );

    test(
      'a request from delete() method hits the right resource',
      () async {
        const serverResponse = <String, dynamic>{};

        dioAdapter.onDelete(
          'http://localhost/posts/1',
          (server) => server.reply(
            200,
            serverResponse,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final post = Post({'id': 1});
        final response =
            await ApiQuery.of(Post.create, current: post).delete<dynamic>();

        expect(response, equals(serverResponse));
      },
    );

    test(
      'a request from delete() method hits the right resource (custom PK)',
      () async {
        const serverResponse = <String, dynamic>{};
        Post.customKey = 'someId';

        final post = Post({'id': 1, 'someId': 'xs911-8cf12', 'text': 'Cool!'});

        dioAdapter.onDelete(
          'http://localhost/posts/${post.someId}',
          (server) => server.reply(
            200,
            serverResponse,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final response =
            await ApiQuery.of(Post.create, current: post).delete<dynamic>();

        expect(response, equals(serverResponse));
      },
    );

    test(
      'a request from delete() when model has not ID throws a exception',
      () async {
        await expectLater(
          () => ApiQuery.of(Post.create, current: Post()).delete<dynamic>(),
          throwsA(
            (dynamic e) =>
                e is ArgumentError &&
                e.message == 'This schema has a empty ID.',
          ),
        );
      },
    );

    test(
      'a request from delete() hits the right resource (nested object)',
      () async {
        const serverResponse = <String, dynamic>{};

        dioAdapter
          ..onGet(
            'http://localhost/posts/1/comments',
            (server) => server.reply(
              200,
              commentsResponse,
              delay: const Duration(milliseconds: 500),
            ),
          )
          ..onDelete(
            'http://localhost/posts/1/comments/1',
            (server) => server.reply(
              200,
              serverResponse,
              delay: const Duration(milliseconds: 500),
            ),
          );

        final post = Post({'id': 1});
        final comment = await post.comments().first();
        expect(comment.text, equals('Hello'));

        final response =
            await post.comments(current: comment).delete<dynamic>();
        expect(response, equals(serverResponse));
      },
    );

    test(
      'a req from delete() hits the right resource (nested obj, customPK)',
      () async {
        Post.customKey = 'someId';
        final post = Post({'id': 1, 'someId': 'xs911-8cf12', 'text': 'Cool!'});
        const serverResponse = <String, dynamic>{};

        dioAdapter
          ..onGet(
            'http://localhost/posts/${post.someId}/comments',
            (server) => server.reply(
              200,
              commentsResponse,
              delay: const Duration(milliseconds: 500),
            ),
          )
          ..onDelete(
            'http://localhost/posts/${post.someId}/comments/1',
            (server) => server.reply(
              200,
              serverResponse,
              delay: const Duration(milliseconds: 500),
            ),
          );

        final comment = await post.comments().first();
        expect(comment.text, equals('Hello'));

        final response =
            await post.comments(current: comment).delete<dynamic>();
        expect(response, equals(serverResponse));
      },
    );

    test('a request with custom() method hits the right resource', () async {
      const serverResponse = <String, dynamic>{};
      dioAdapter.onGet(
        'http://localhost/postz',
        (server) => server.reply(
          200,
          serverResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final query = ApiQuery.of(Post.create)..custom(['postz']);
      final response = await query.first();

      expect(response.attributes, equals(serverResponse));
    });

    test(
      'custom() called with multiple obj/strings gets the correct resource',
      () async {
        const serverResponse = <String, dynamic>{};
        dioAdapter.onGet(
          'http://localhost/users/1/postz/comments',
          (server) => server.reply(
            200,
            serverResponse,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final user = User({'id': 1});
        final comment = Comment();

        final response = await (ApiQuery.of(Comment.create)
              ..custom([user, 'postz', comment]))
            .getOrNull();

        expect(response, isNotNull);
      },
    );

    test('a request from load() method hits right resource', () async {
      const serverResponse = <String, dynamic>{};
      dioAdapter.onGet(
        'http://localhost/users/1/posts',
        (server) => server.reply(
          200,
          serverResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final user = User({'id': 1});
      final response = await user.posts().get();
      expect(response, isNotNull);
    });

    test(
      'a request from load() with a find() hits right resource',
      () async {
        const serverResponse = <String, dynamic>{};
        dioAdapter.onGet(
          'http://localhost/users/1/posts/1',
          (server) => server.reply(
            200,
            serverResponse,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final user = User({'id': 1});
        final response = await user.posts().find(1);
        expect(response, isNotNull);
      },
    );

    test('a request from load() method returns a array of Models', () async {
      dioAdapter.onGet(
        'http://localhost/users/1/posts',
        (server) => server.reply(
          200,
          postsResponse,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final user = User({'id': 1});
      final posts = await user.posts().get();

      expect(posts, everyElement(isA<Post>()));
    });

    test('paginate() method returns a resource paginate', () async {
      dioAdapter.onGet(
        'http://localhost/posts',
        (server) => server.reply(
          200,
          postsResponsePaginate,
          delay: const Duration(milliseconds: 500),
        ),
      );

      final postsPaginate = await ApiQuery.of(Post.create).paginate();
      expect(postsPaginate, isA<ResourcePagination>());

      expect(postsPaginate.total, equals(2));
      expect(postsPaginate.models, everyElement(isA<Post>()));
    });

    test(
      'paginateOrNull() method returns a null if response is not paginate',
      () async {
        dioAdapter.onGet(
          'http://localhost/posts',
          (server) => server.reply(
            200,
            postsResponse,
            delay: const Duration(milliseconds: 500),
          ),
        );

        final postsPaginate = await ApiQuery.of(Post.create).paginateOrNull();
        expect(postsPaginate, isNull);
      },
    );
  });
}
