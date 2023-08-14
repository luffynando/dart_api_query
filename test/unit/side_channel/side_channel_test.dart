import 'package:dart_api_query/src/side_channel/side_channel.dart';
import 'package:test/test.dart';

void main() {
  group('Side Channel', () {
    test('contains', () {
      final channel = SideChannel();
      expect(
        () => channel.contain(<dynamic>{}),
        throwsA(
          (dynamic e) =>
              e is AssertionError &&
              e.message == 'Side channel does not contain key',
        ),
      );

      final o = <dynamic>{};
      channel.set(o, 'data');
      expect(
        () => channel.contain(o),
        isNot(throwsException),
        reason: 'Existent value',
      );
    });

    test('has', () {
      final channel = SideChannel();
      final o = <dynamic>[];
      expect(
        channel.has(o),
        isFalse,
        reason: 'non existent value yields false',
      );

      channel.set(o, 'foo');
      expect(channel.has(o), isTrue, reason: 'existent value yields true');
      expect(
        channel.has('abs'),
        isFalse,
        reason: 'non object value non existent yields false',
      );

      channel.set('abc', 'foo');
      expect(
        channel.has('abc'),
        isTrue,
        reason: 'non object value that exists yields true',
      );
    });

    test('get', () {
      final channel = SideChannel();
      final o = <dynamic>{};
      expect(channel.get(o), isNull, reason: 'non existent value yields null');

      final data = <dynamic>{};
      channel.set(o, data);
      expect(
        channel.get(o),
        equals(data),
        reason: '"get" yields data set by "set"',
      );
    });

    test('set', () {
      final channel = SideChannel();
      void o() {}
      expect(channel.get(o), isNull, reason: 'value not set');

      channel.set(o, 42);
      expect(channel.get(o), equals(42), reason: 'value was set');

      const infinity = 1.0 / 0.0;
      channel.set(o, infinity);
      expect(channel.get(o), equals(infinity), reason: 'value was set again');

      final o2 = <dynamic>{};
      channel.set(o2, 17);
      expect(channel.get(o), equals(infinity), reason: 'o is not modified');
      expect(channel.get(o2), equals(17), reason: 'o2 is set');

      channel.set(o, 14);
      expect(channel.get(o), equals(14), reason: 'o is modified');
      expect(channel.get(o2), equals(17), reason: 'o2 is not modified');
    });
  });
}
