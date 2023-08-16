import 'package:dart_api_query/src/api_query.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import '../dummy/models/model_with_param_names.dart';
import '../dummy/models/post.dart';
import '../dummy/models/post_with_options.dart';

void main() {
  group('Query builder', () {
    setUp(() {
      final dio = Dio(BaseOptions());
      ApiQuery.http = dio;
      ApiQuery.baseURL = '';
    });

    test('it builds a complex query', () {
      final post = ApiQuery.of(Post.new)
        ..include(['user'])
        ..append(['likes'])
        ..selectFromRelations({
          'posts': ['title', 'content'],
          'user': ['age', 'firstname']
        })
        ..where('title', 'Cool')
        ..where('status', 'ACTIVE')
        ..page(3)
        ..limit(10)
        ..orderBy(['created_at'])
        ..params({'doSomething': 'yes', 'process': 'no'});

      final query = [
        '?include=user',
        '&append=likes',
        '&fields[posts]=title,content',
        '&fields[user]=age,firstname',
        '&filter[title]=Cool',
        '&filter[status]=ACTIVE',
        '&sort=created_at',
        '&page=3',
        '&limit=10',
        '&doSomething=yes',
        '&process=no'
      ].join();

      expect(post.getBuilder().query(), equals(query));
    });

    test('it builds a complex query with custom param names', () {
      final model = ApiQuery.of(ModelWithParamNames.new)
        ..include(['user'])
        ..append(['likes'])
        ..selectFromRelations({
          'posts': ['title', 'content'],
          'user': ['age', 'firstname']
        })
        ..where('title', 'Cool')
        ..where('status', 'ACTIVE')
        ..page(3)
        ..limit(10)
        ..orderBy(['created_at']);

      final query = [
        '?include_custom=user',
        '&append_custom=likes',
        '&fields_custom[posts]=title,content',
        '&fields_custom[user]=age,firstname',
        '&filter_custom[title]=Cool',
        '&filter_custom[status]=ACTIVE',
        '&sort_custom=created_at',
        '&page_custom=3',
        '&limit_custom=10'
      ].join();

      expect(model.getBuilder().query(), equals(query));
    });

    test('it can change default array format option', () {
      var post = ApiQuery.of(PostWithOptions.new)
        ..include(['user'])
        ..whereIn('status', ['published', 'archived']);
      expect(
        post.getBuilder().query(),
        equals(
          [
            '?include=user',
            '&filter[status][0]=published',
            '&filter[status][1]=archived'
          ].join(),
        ),
      );
      expect(
        post.getBuilder().filters,
        equals({
          'status': ['published', 'archived']
        }),
      );

      post = ApiQuery.of(PostWithOptions.new)
        ..include(['user'])
        ..whereInNested({
          'user': {
            'status': ['active', 'inactive']
          }
        });
      expect(
        post.getBuilder().query(),
        equals(
          [
            '?include=user',
            '&filter[user][status][0]=active',
            '&filter[user][status][1]=inactive',
          ].join(),
        ),
      );
      expect(
        post.getBuilder().filters,
        equals({
          'user': {
            'status': ['active', 'inactive']
          }
        }),
      );
    });

    test('include() sets properly the builder', () {
      var post = ApiQuery.of(Post.new)..include(['user']);
      expect(post.getBuilder().includes, equals(['user']));

      post = ApiQuery.of(Post.new)..include(['user', 'category']);
      expect(post.getBuilder().includes, equals(['user', 'category']));
    });

    test('load() sets properly the builder', () {
      var post = ApiQuery.of(Post.new)..load(['user']);
      expect(post.getBuilder().includes, equals(['user']));

      post = ApiQuery.of(Post.new)..load(['user', 'category']);
      expect(post.getBuilder().includes, equals(['user', 'category']));
    });

    test('append() sets properly the builder', () {
      var post = ApiQuery.of(Post.new)..append(['likes']);
      expect(post.getBuilder().appends, equals(['likes']));

      post = ApiQuery.of(Post.new)..append(['likes', 'visits']);
      expect(post.getBuilder().appends, equals(['likes', 'visits']));
    });

    test('orderBy() sets properly the builder', () {
      var post = ApiQuery.of(Post.new)..orderBy(['created_at']);
      expect(post.getBuilder().sorts, equals(['created_at']));

      post = ApiQuery.of(Post.new)..orderBy(['created_at', '-visits']);
      expect(post.getBuilder().sorts, equals(['created_at', '-visits']));
    });

    test('where() and whereNested() sets properly the builder', () {
      var post = ApiQuery.of(Post.new)..where('id', 1);
      expect(post.getBuilder().filters, equals({'id': 1}));

      post = ApiQuery.of(Post.new)
        ..where('id', 1)
        ..where('title', 'Cool');
      expect(post.getBuilder().filters, equals({'id': 1, 'title': 'Cool'}));

      post = ApiQuery.of(Post.new)
        ..whereNested({
          'user': {'status': 'active'}
        });
      expect(
        post.getBuilder().filters,
        equals({
          'user': {'status': 'active'}
        }),
      );
      expect(post.getBuilder().query(), equals('?filter[user][status]=active'));

      post = ApiQuery.of(Post.new)
        ..whereNested({
          'schedule': {'start': '2020-11-27'}
        })
        ..whereNested({
          'schedule': {'end': '2020-11-28'}
        });
      expect(
        post.getBuilder().filters,
        equals({
          'schedule': {'start': '2020-11-27', 'end': '2020-11-28'}
        }),
      );
      expect(
        post.getBuilder().query(),
        equals(
          [
            '?filter[schedule][start]=2020-11-27',
            '&filter[schedule][end]=2020-11-28'
          ].join(),
        ),
      );

      post = ApiQuery.of(Post.new)
        ..whereNested({'id': 1, 'title': 'Cool'})
        ..when(
          true,
          (query, _) => query
            ..whereNested({
              'user': {'status': 'active'}
            }),
        );
      expect(
        post.getBuilder().filters,
        equals({
          'id': 1,
          'title': 'Cool',
          'user': {'status': 'active'}
        }),
      );
    });

    test('where() throws a exception when does´t not have values', () {
      expect(
        () => ApiQuery.of(Post.new)..where('id', null),
        throwsA(
          (dynamic e) =>
              e is ArgumentError &&
              e.message == 'The VALUE is required on where() method.',
        ),
      );
    });

    test('where() throws a exception when second parameter is not primitive',
        () {
      expect(
        () => ApiQuery.of(Post.new)..where('id', ['foo']),
        throwsA(
          (dynamic e) =>
              e is ArgumentError &&
              e.message == 'The VALUE must be primitive on where() method.',
        ),
      );
    });

    test('whereIn() and whereInNested sets properly the builder', () {
      var post = ApiQuery.of(Post.new)
        ..whereIn('status', ['ACTIVE', 'ARCHIVED']);
      expect(
        post.getBuilder().filters,
        equals({
          'status': ['ACTIVE', 'ARCHIVED']
        }),
      );

      post = ApiQuery.of(Post.new)
        ..whereInNested({
          'user': {
            'status': ['active', 'inactive']
          }
        });
      expect(
        post.getBuilder().filters,
        equals({
          'user': {
            'status': ['active', 'inactive'],
          },
        }),
      );
      expect(
        post.getBuilder().query(),
        equals('?filter[user][status]=active,inactive'),
      );

      post = ApiQuery.of(Post.new)
        ..whereInNested({
          'schedule': {
            'start': ['2020-11-27', '2020-11-28']
          }
        })
        ..whereInNested({
          'schedule': {
            'end': ['2020-11-28', '2020-11-29']
          }
        });

      expect(
        post.getBuilder().filters,
        equals({
          'schedule': {
            'start': ['2020-11-27', '2020-11-28'],
            'end': ['2020-11-28', '2020-11-29']
          }
        }),
      );
      expect(
        post.getBuilder().query(),
        equals(
          [
            '?filter[schedule][start]=2020-11-27,2020-11-28',
            '&filter[schedule][end]=2020-11-28,2020-11-29'
          ].join(),
        ),
      );

      post = ApiQuery.of(Post.new)
        ..whereInNested({
          'status': ['ACTIVE', 'ARCHIVED']
        })
        ..when(
          true,
          (query, _) => query
            ..whereInNested({
              'user': {
                'status': ['active', 'inactive']
              }
            }),
        );

      expect(
        post.getBuilder().filters,
        equals({
          'status': ['ACTIVE', 'ARCHIVED'],
          'user': {
            'status': ['active', 'inactive']
          }
        }),
      );
    });

    test('page() sets properly the builder', () {
      final post = ApiQuery.of(Post.new)..page(3);
      expect(post.getBuilder().pageValue, equals(3));
    });

    test('limit() sets properly the builder', () {
      final post = ApiQuery.of(Post.new)..limit(10);
      expect(post.getBuilder().limitValue, equals(10));
    });

    test('select() with no parameters', () {
      expect(
        () => ApiQuery.of(Post.new)..select([]),
        throwsA(
          (dynamic e) =>
              e is ArgumentError &&
              e.message == 'You must specify the fields on select() method.',
        ),
      );
    });

    test('select() for single entity', () {
      final post = ApiQuery.of(Post.new)..select(['age', 'firstname']);
      expect(post.getBuilder().fields['posts'], equals(['age', 'firstname']));
    });

    test('select() for related entities', () {
      final post = ApiQuery.of(Post.new)
        ..selectFromRelations({
          'posts': ['title', 'content'],
          'user': ['age', 'firstname']
        });

      expect(post.getBuilder().fields['posts'], equals(['title', 'content']));
      expect(post.getBuilder().fields['user'], equals(['age', 'firstname']));
    });

    test('params() sets properly the builder', () {
      var post = ApiQuery.of(Post.new)..params({'doSomething': 'yes'});

      expect(post.getBuilder().payload, equals({'doSomething': 'yes'}));

      post = ApiQuery.of(Post.new)
        ..params({
          'foo': 'bar',
          'baz': ['a', 'b']
        });

      expect(
        post.getBuilder().payload,
        equals({
          'foo': 'bar',
          'baz': ['a', 'b']
        }),
      );
      expect(post.getBuilder().query(), equals('?foo=bar&baz=a,b'));
    });

    test('when() sets properly the builder', () {
      var search = '';
      var post = ApiQuery.of(Post.new)
        ..when(search, (query, value) => query..where('title', value));

      expect(post.getBuilder().filters, equals({}));

      search = 'foo';
      post = ApiQuery.of(Post.new)
        ..when(search, (query, value) => query..where('title', value));

      expect(post.getBuilder().filters, equals({'title': 'foo'}));
    });

    test('resets uri upon query gen when query is regen a second time', () {
      final post = ApiQuery.of(Post.new)
        ..where('title', 'Cool')
        ..page(4);
      const query = '?filter[title]=Cool&page=4';

      expect(post.getBuilder().query(), equals(query));
      expect(post.getBuilder().query(), equals(query));
    });
  });
}
