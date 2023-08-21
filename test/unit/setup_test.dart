import 'package:dart_api_query/src/api_query.dart';
import 'package:test/test.dart';

import '../dummy/models/empty_base_model.dart';
import '../dummy/models/post.dart';

void main() {
  group('Setup models', () {
    test('it throws an error if ApiQuery.http property has not been set', () {
      EmptyBaseModel.reset();
      EmptyBaseModel.withBaseURL();

      expect(
        () => ApiQuery.of(EmptyBaseModel.create),
        throwsA(
          (dynamic e) =>
              e is ArgumentError &&
              e.message == 'You must set ApiQuery.http property.',
        ),
      );
    });

    test('it throws an error if baseURL() method was not declared', () {
      EmptyBaseModel.reset();
      EmptyBaseModel.withHttp();

      expect(
        () => ApiQuery.of(EmptyBaseModel.create),
        throwsA(
          (dynamic e) =>
              e is ArgumentError &&
              e.message ==
                  [
                    'You must assign ApiQuery.baseURL property',
                    ' or model baseURL() method.'
                  ].join(),
        ),
      );
    });

    test('the resource() method pluralizes the class name', () {
      final post = Post();
      expect(post.resource(), equals('posts'));
    });
  });
}
