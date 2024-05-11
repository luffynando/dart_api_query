// ignore_for_file: avoid_redundant_argument_values, omit_local_variable_types

import 'dart:convert' show Encoding, latin1, utf8;

import 'package:qs_dart/qs_dart.dart';
import 'package:qs_dart/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('stringify()', () {
    test('encodes a query string object', () {
      expect(QS.encode({'a': 'b'}), equals('a=b'));
      expect(QS.encode({'a': 1}), equals('a=1'));
      expect(QS.encode({'a': 1, 'b': 2}), equals('a=1&b=2'));
      expect(QS.encode({'a': 'A_Z'}), equals('a=A_Z'));
      expect(QS.encode({'a': '€'}), equals('a=%E2%82%AC'));
      expect(QS.encode({'a': ''}), equals('a=%EE%80%80'));
      expect(QS.encode({'a': 'א'}), equals('a=%D7%90'));
      expect(QS.encode({'a': '𐐷'}), equals('a=%F0%90%90%B7'));
    });

    test('encodes falsy values', () {
      expect(QS.encode(null), equals(''));
      expect(
        QS.encode(null, const EncodeOptions(strictNullHandling: true)),
        equals(''),
      );
      expect(QS.encode(false), equals(''));
      expect(QS.encode(0), equals(''));
    });

    test('encodes big ints', () {
      final three = BigInt.from(3);
      String encodeWithN(
        dynamic value, {
        Encoding? charset,
        Format? format,
      }) {
        // ignore: invalid_use_of_internal_member
        final String result = Utils.encode(
          value.toString(),
          charset: charset ?? utf8,
        );
        return value is BigInt ? '${result}n' : result;
      }

      expect(QS.encode(three), equals(''));
      expect(QS.encode([three]), equals('0=3'));
      expect(
        QS.encode([three], EncodeOptions(encoder: encodeWithN)),
        equals('0=3n'),
      );
      expect(QS.encode({'a': three}), equals('a=3'));
      expect(
        QS.encode(
          {'a': three},
          EncodeOptions(encoder: encodeWithN),
        ),
        equals('a=3n'),
      );
      expect(
        QS.encode(
          {
            'a': [three],
          },
          const EncodeOptions(
            encodeValuesOnly: true,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[]=3'),
      );
      expect(
        QS.encode(
          {
            'a': [three],
          },
          EncodeOptions(
            encodeValuesOnly: true,
            encoder: encodeWithN,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[]=3n'),
      );
    });

    test('adds query prefix', () {
      expect(
        QS.encode({'a': 'b'}, const EncodeOptions(addQueryPrefix: true)),
        equals('?a=b'),
      );
    });

    test('with query prefix, outputs blank string given an empty object', () {
      expect(
        QS.encode(
          <String, dynamic>{},
          const EncodeOptions(addQueryPrefix: true),
        ),
        equals(''),
      );
    });

    test('encodes nested falsy values', () {
      expect(
        QS.encode({
          'a': {
            'b': {'c': null},
          },
        }),
        equals('a%5Bb%5D%5Bc%5D='),
      );
      expect(
        QS.encode(
          {
            'a': {
              'b': {'c': null},
            },
          },
          const EncodeOptions(strictNullHandling: true),
        ),
        equals('a%5Bb%5D%5Bc%5D'),
      );
      expect(
        QS.encode({
          'a': {
            'b': {'c': false},
          },
        }),
        equals('a%5Bb%5D%5Bc%5D=false'),
      );
    });

    test('encodes a nested object', () {
      expect(
        QS.encode({
          'a': {'b': 'c'},
        }),
        equals('a%5Bb%5D=c'),
      );
      expect(
        QS.encode({
          'a': {
            'b': {
              'c': {'d': 'e'},
            },
          },
        }),
        equals('a%5Bb%5D%5Bc%5D%5Bd%5D=e'),
      );
    });

    test('encodes a nested object with dots notation', () {
      expect(
        QS.encode(
          {
            'a': {'b': 'c'},
          },
          const EncodeOptions(allowDots: true),
        ),
        equals('a.b=c'),
      );
      expect(
        QS.encode(
          {
            'a': {
              'b': {
                'c': {'d': 'e'},
              },
            },
          },
          const EncodeOptions(allowDots: true),
        ),
        equals('a.b.c.d=e'),
      );
    });

    test('encodes an array value', () {
      expect(
        QS.encode(
          {
            'a': ['b', 'c', 'd'],
          },
          const EncodeOptions(listFormat: ListFormat.indices),
        ),
        equals('a%5B0%5D=b&a%5B1%5D=c&a%5B2%5D=d'),
        reason: 'indices => indices',
      );
      expect(
        QS.encode(
          {
            'a': ['b', 'c', 'd'],
          },
          const EncodeOptions(listFormat: ListFormat.brackets),
        ),
        equals('a%5B%5D=b&a%5B%5D=c&a%5B%5D=d'),
        reason: 'brackets => brackets',
      );
      expect(
        QS.encode(
          {
            'a': ['b', 'c', 'd'],
          },
          const EncodeOptions(listFormat: ListFormat.comma),
        ),
        equals('a=b%2Cc%2Cd'),
        reason: 'comma => comma',
      );
      expect(
        QS.encode({
          'a': ['b', 'c', 'd'],
        }),
        equals('a%5B0%5D=b&a%5B1%5D=c&a%5B2%5D=d'),
        reason: 'default => indices',
      );
    });

    test('omits nulls when asked', () {
      expect(
        QS.encode(
          {'a': 'b', 'c': null},
          const EncodeOptions(skipNulls: true),
        ),
        equals('a=b'),
      );
    });

    test('omits nested null when asked', () {
      expect(
        QS.encode(
          {
            'a': {'b': 'c', 'd': null},
          },
          const EncodeOptions(skipNulls: true),
        ),
        equals('a%5Bb%5D=c'),
      );
    });

    test('omits array indices when asked', () {
      expect(
        QS.encode(
          {
            'a': ['b', 'c', 'd'],
          },
          // ignore: deprecated_member_use
          const EncodeOptions(indices: false),
        ),
        equals('a=b&a=c&a=d'),
      );
    });

    group('encodes an array value with one item vs multiple items', () {
      test('non-array item', () {
        expect(
          QS.encode(
            {'a': 'c'},
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.indices,
            ),
          ),
          equals('a=c'),
        );
        expect(
          QS.encode(
            {'a': 'c'},
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.brackets,
            ),
          ),
          equals('a=c'),
        );
        expect(
          QS.encode(
            {'a': 'c'},
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.comma,
            ),
          ),
          equals('a=c'),
        );
        expect(
          QS.encode(
            {'a': 'c'},
            const EncodeOptions(encodeValuesOnly: true),
          ),
          equals('a=c'),
        );
      });

      test('array with a single item', () {
        expect(
          QS.encode(
            {
              'a': ['c'],
            },
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.indices,
            ),
          ),
          equals('a[0]=c'),
        );
        expect(
          QS.encode(
            {
              'a': ['c'],
            },
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.brackets,
            ),
          ),
          equals('a[]=c'),
        );
        expect(
          QS.encode(
            {
              'a': ['c'],
            },
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.comma,
            ),
          ),
          equals('a=c'),
        );
        expect(
          QS.encode(
            {
              'a': ['c'],
            },
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.comma,
              commaRoundTrip: true,
            ),
          ),
          equals('a[]=c'),
        );
        expect(
          QS.encode(
            {
              'a': ['c'],
            },
            const EncodeOptions(encodeValuesOnly: true),
          ),
          equals('a[0]=c'),
        );
      });

      test('array with multiple items', () {
        expect(
          QS.encode(
            {
              'a': ['c', 'd'],
            },
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.indices,
            ),
          ),
          equals('a[0]=c&a[1]=d'),
        );
        expect(
          QS.encode(
            {
              'a': ['c', 'd'],
            },
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.brackets,
            ),
          ),
          equals('a[]=c&a[]=d'),
        );
        expect(
          QS.encode(
            {
              'a': ['c', 'd'],
            },
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.comma,
            ),
          ),
          equals('a=c,d'),
        );
        expect(
          QS.encode(
            {
              'a': ['c', 'd'],
            },
            const EncodeOptions(encodeValuesOnly: true),
          ),
          equals('a[0]=c&a[1]=d'),
        );
      });

      test('array with multiple items with a comma inside', () {
        expect(
          QS.encode(
            {
              'a': ['c,d', 'e'],
            },
            const EncodeOptions(
              encodeValuesOnly: true,
              listFormat: ListFormat.comma,
            ),
          ),
          equals('a=c%2Cd,e'),
        );
        expect(
          QS.encode(
            {
              'a': ['c,d', 'e'],
            },
            const EncodeOptions(listFormat: ListFormat.comma),
          ),
          equals('a=c%2Cd%2Ce'),
        );
      });
    });

    test('encodes a nested array value', () {
      expect(
        QS.encode(
          {
            'a': {
              'b': ['c', 'd'],
            },
          },
          const EncodeOptions(
            encodeValuesOnly: true,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a[b][0]=c&a[b][1]=d'),
      );
      expect(
        QS.encode(
          {
            'a': {
              'b': ['c', 'd'],
            },
          },
          const EncodeOptions(
            encodeValuesOnly: true,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[b][]=c&a[b][]=d'),
      );
      expect(
        QS.encode(
          {
            'a': {
              'b': ['c', 'd'],
            },
          },
          const EncodeOptions(
            encodeValuesOnly: true,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a[b]=c,d'),
      );
      expect(
        QS.encode(
          {
            'a': {
              'b': ['c', 'd'],
            },
          },
          const EncodeOptions(encodeValuesOnly: true),
        ),
        equals('a[b][0]=c&a[b][1]=d'),
      );
    });

    test('encodes comma and empty array values', () {
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a[0]=,&a[1]=&a[2]=c,d%'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[]=,&a[]=&a[]=c,d%'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a=,,,c,d%'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.repeat,
          ),
        ),
        equals('a=,&a=&a=c,d%'),
      );

      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a[0]=%2C&a[1]=&a[2]=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[]=%2C&a[]=&a[]=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a=%2C,,c%2Cd%25'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.repeat,
          ),
        ),
        equals('a=%2C&a=&a=c%2Cd%25'),
      );

      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a%5B0%5D=%2C&a%5B1%5D=&a%5B2%5D=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a%5B%5D=%2C&a%5B%5D=&a%5B%5D=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: false,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a=%2C%2C%2Cc%2Cd%25'),
      );
      expect(
        QS.encode(
          {
            'a': [',', '', 'c,d%'],
          },
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: false,
            listFormat: ListFormat.repeat,
          ),
        ),
        equals('a=%2C&a=&a=c%2Cd%25'),
      );
    });

    test('encodes comma and empty non-array values', () {
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a=,&b=&c=c,d%'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a=,&b=&c=c,d%'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a=,&b=&c=c,d%'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.repeat,
          ),
        ),
        equals('a=,&b=&c=c,d%'),
      );

      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.repeat,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );

      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: false,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        QS.encode(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          const EncodeOptions(
            encode: true,
            encodeValuesOnly: false,
            listFormat: ListFormat.repeat,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
    });

    test('encodes a nested array value with dots notation', () {
      expect(
        QS.encode(
          {
            'a': {
              'b': ['c', 'd'],
            },
          },
          const EncodeOptions(
            allowDots: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a.b[0]=c&a.b[1]=d'),
        reason: 'indices: encodes with dots + indices',
      );
      expect(
        QS.encode(
          {
            'a': {
              'b': ['c', 'd'],
            },
          },
          const EncodeOptions(
            allowDots: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a.b[]=c&a.b[]=d'),
        reason: 'brackets: encodes with dots + brackets',
      );
      expect(
        QS.encode(
          {
            'a': {
              'b': ['c', 'd'],
            },
          },
          const EncodeOptions(
            allowDots: true,
            encodeValuesOnly: true,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a.b=c,d'),
        reason: 'comma: encodes with dots + comma',
      );
      expect(
        QS.encode(
          {
            'a': {
              'b': ['c', 'd'],
            },
          },
          const EncodeOptions(
            allowDots: true,
            encodeValuesOnly: true,
          ),
        ),
        equals('a.b[0]=c&a.b[1]=d'),
        reason: 'default: encodes with dots + indices',
      );
    });

    test('encodes an object inside an array', () {
      expect(
        QS.encode(
          {
            'a': [
              {'b': 'c'},
            ],
          },
          const EncodeOptions(listFormat: ListFormat.indices),
        ),
        equals('a%5B0%5D%5Bb%5D=c'), // a[0][b]=c
        reason: 'indices => brackets',
      );
      expect(
        QS.encode(
          {
            'a': [
              {'b': 'c'},
            ],
          },
          const EncodeOptions(listFormat: ListFormat.brackets),
        ),
        equals('a%5B%5D%5Bb%5D=c'), // a[][b]=c
        reason: 'brackets => brackets',
      );
      expect(
        QS.encode({
          'a': [
            {'b': 'c'},
          ],
        }),
        equals('a%5B0%5D%5Bb%5D=c'),
        reason: 'default => indices',
      );

      expect(
        QS.encode(
          {
            'a': [
              {
                'b': {
                  'c': [1],
                },
              }
            ],
          },
          const EncodeOptions(listFormat: ListFormat.indices),
        ),
        equals('a%5B0%5D%5Bb%5D%5Bc%5D%5B0%5D=1'),
        reason: 'indices => indices',
      );
      expect(
        QS.encode(
          {
            'a': [
              {
                'b': {
                  'c': [1],
                },
              }
            ],
          },
          const EncodeOptions(listFormat: ListFormat.brackets),
        ),
        equals('a%5B%5D%5Bb%5D%5Bc%5D%5B%5D=1'),
        reason: 'brackets => brackets',
      );
      expect(
        QS.encode({
          'a': [
            {
              'b': {
                'c': [1],
              },
            }
          ],
        }),
        equals('a%5B0%5D%5Bb%5D%5Bc%5D%5B0%5D=1'),
        reason: 'default => indices',
      );
    });

    test('encodes an array with mixed objects and primitives', () {
      expect(
        QS.encode(
          {
            'a': [
              {'b': 1},
              2,
              3,
            ],
          },
          const EncodeOptions(
            encodeValuesOnly: true,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a[0][b]=1&a[1]=2&a[2]=3'),
        reason: 'indices => indices',
      );
      expect(
        QS.encode(
          {
            'a': [
              {'b': 1},
              2,
              3,
            ],
          },
          const EncodeOptions(
            encodeValuesOnly: true,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[][b]=1&a[]=2&a[]=3'),
        reason: 'brackets => brackets',
      );
      expect(
        QS.encode(
          {
            'a': [
              {'b': 1},
              2,
              3,
            ],
          },
          const EncodeOptions(encodeValuesOnly: true),
        ),
        equals('a[0][b]=1&a[1]=2&a[2]=3'),
        reason: 'default => indices',
      );
    });

    test('encodes an object inside an array with dots notation', () {
      expect(
        QS.encode(
          {
            'a': [
              {'b': 'c'},
            ],
          },
          const EncodeOptions(
            allowDots: true,
            encode: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a[0].b=c'),
        reason: 'indices => indices',
      );
      expect(
        QS.encode(
          {
            'a': [
              {'b': 'c'},
            ],
          },
          const EncodeOptions(
            allowDots: true,
            encode: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[].b=c'),
        reason: 'brackets => brackets',
      );
      expect(
        QS.encode(
          {
            'a': [
              {'b': 'c'},
            ],
          },
          const EncodeOptions(
            allowDots: true,
            encode: false,
          ),
        ),
        equals('a[0].b=c'),
        reason: 'default => indices',
      );

      expect(
        QS.encode(
          {
            'a': [
              {
                'b': {
                  'c': [1],
                },
              }
            ],
          },
          const EncodeOptions(
            allowDots: true,
            encode: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a[0].b.c[0]=1'),
        reason: 'indices => indices',
      );
      expect(
        QS.encode(
          {
            'a': [
              {
                'b': {
                  'c': [1],
                },
              }
            ],
          },
          const EncodeOptions(
            allowDots: true,
            encode: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[].b.c[]=1'),
        reason: 'brackets => brackets',
      );
      expect(
        QS.encode(
          {
            'a': [
              {
                'b': {
                  'c': [1],
                },
              }
            ],
          },
          const EncodeOptions(
            allowDots: true,
            encode: false,
          ),
        ),
        equals('a[0].b.c[0]=1'),
        reason: 'default => indices',
      );
    });

    test('does not omit object keys when indices = false', () {
      expect(
        QS.encode(
          {
            'a': [
              {'b': 'c'},
            ],
          },
          // ignore: deprecated_member_use
          const EncodeOptions(indices: false),
        ),
        equals('a%5Bb%5D=c'),
      );
    });

    test('uses indices notation for arrays when indices=true', () {
      expect(
        QS.encode(
          {
            'a': ['b', 'c'],
          },
          // ignore: deprecated_member_use
          const EncodeOptions(indices: true),
        ),
        equals('a%5B0%5D=b&a%5B1%5D=c'),
      );
    });

    test('uses indices notation for arrays when no listFormat is specified',
        () {
      expect(
        QS.encode({
          'a': ['b', 'c'],
        }),
        equals('a%5B0%5D=b&a%5B1%5D=c'),
      );
    });

    test('uses indices notation for arrays when listFormat=indices', () {
      expect(
        QS.encode(
          {
            'a': ['b', 'c'],
          },
          const EncodeOptions(listFormat: ListFormat.indices),
        ),
        equals('a%5B0%5D=b&a%5B1%5D=c'),
      );
    });

    test('uses repeat notation for arrays when no listFormat=repeat', () {
      expect(
        QS.encode(
          {
            'a': ['b', 'c'],
          },
          const EncodeOptions(listFormat: ListFormat.repeat),
        ),
        equals('a=b&a=c'),
      );
    });

    test('uses brackets notation for arrays when no listFormat=brackets', () {
      expect(
        QS.encode(
          {
            'a': ['b', 'c'],
          },
          const EncodeOptions(listFormat: ListFormat.brackets),
        ),
        equals('a%5B%5D=b&a%5B%5D=c'),
      );
    });

    test('encodes a complicated object', () {
      expect(
        QS.encode({
          'a': {'b': 'c', 'd': 'e'},
        }),
        equals('a%5Bb%5D=c&a%5Bd%5D=e'),
      );
    });

    test('encodes an empty value', () {
      expect(QS.encode({'a': ''}), equals('a='));
      expect(
        QS.encode(
          {'a': null},
          const EncodeOptions(strictNullHandling: true),
        ),
        equals('a'),
      );

      expect(QS.encode({'a': '', 'b': ''}), equals('a=&b='));
      expect(
        QS.encode(
          {'a': null, 'b': ''},
          const EncodeOptions(strictNullHandling: true),
        ),
        equals('a&b='),
      );

      expect(
        QS.encode({
          'a': {'b': ''},
        }),
        equals('a%5Bb%5D='),
      );
      expect(
        QS.encode(
          {
            'a': {'b': null},
          },
          const EncodeOptions(strictNullHandling: true),
        ),
        equals('a%5Bb%5D'),
      );
      expect(
        QS.encode(
          {
            'a': {'b': null},
          },
          const EncodeOptions(strictNullHandling: false),
        ),
        equals('a%5Bb%5D='),
      );
    });

    test('encodes an empty array in different listFormat', () {
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(encode: false),
        ),
        equals('b[0]=&c=c'),
      );
      // listFormat default
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('b[0]=&c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('b[]=&c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.repeat,
          ),
        ),
        equals('b=&c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('b=&c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.comma,
            commaRoundTrip: true,
          ),
        ),
        equals('b[]=&c=c'),
      );
      // with strictNullHandling
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.indices,
            strictNullHandling: true,
          ),
        ),
        equals('b[0]&c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.brackets,
            strictNullHandling: true,
          ),
        ),
        equals('b[]&c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.repeat,
            strictNullHandling: true,
          ),
        ),
        equals('b&c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.comma,
            strictNullHandling: true,
          ),
        ),
        equals('b&c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.comma,
            commaRoundTrip: true,
            strictNullHandling: true,
          ),
        ),
        equals('b[]&c=c'),
      );
      // with skipNulls
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.indices,
            skipNulls: true,
          ),
        ),
        equals('c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.brackets,
            skipNulls: true,
          ),
        ),
        equals('c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.repeat,
            skipNulls: true,
          ),
        ),
        equals('c=c'),
      );
      expect(
        QS.encode(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c',
          },
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.comma,
            skipNulls: true,
          ),
        ),
        equals('c=c'),
      );
    });

    test('returns an empty string for invalid input', () {
      expect(QS.encode(false), equals(''));
      expect(QS.encode(null), equals(''));
      expect(QS.encode(''), equals(''));
    });

    test('url encodes values', () {
      expect(QS.encode({'a': 'b c'}), equals('a=b%20c'));
    });

    test('encodes a date', () {
      final now = DateTime.now();
      final str = 'a=${Uri.encodeComponent(now.toIso8601String())}';
      expect(QS.encode({'a': now}), equals(str));
    });

    test('encodes the weird object from qs', () {
      expect(
        QS.encode({'my weird field': '~q1!2"\'w\$5&7/z8)?'}),
        equals('my%20weird%20field=~q1%212%22%27w%245%267%2Fz8%29%3F'),
      );
    });

    test('encodes boolean values', () {
      expect(QS.encode({'a': true}), equals('a=true'));
      expect(
        QS.encode({
          'a': {'b': true},
        }),
        equals('a%5Bb%5D=true'),
      );
      expect(QS.encode({'b': false}), equals('b=false'));
      expect(
        QS.encode({
          'b': {'c': false},
        }),
        equals('b%5Bc%5D=false'),
      );
    });

    test('encodes buffer values', () {
      expect(QS.encode({'a': StringBuffer('test')}), equals('a=test'));
      expect(
        QS.encode({
          'a': {'b': StringBuffer('test')},
        }),
        equals('a%5Bb%5D=test'),
      );
    });

    test('encodes an object using an alternative delimiter', () {
      expect(
        QS.encode(
          {'a': 'b', 'c': 'd'},
          const EncodeOptions(delimiter: ';'),
        ),
        equals('a=b;c=d'),
      );
    });

    test('does not crash when parsing circular references', () {
      final a = <String, dynamic>{};
      a['b'] = a;
      expect(
        () => QS.encode({'foo[bar]': 'baz', 'foo[baz]': a}),
        throwsA(
          predicate(
            (e) => e is RangeError && e.message == 'Cyclic object value',
          ),
        ),
      );

      final circular = <String, dynamic>{'a': 'value'};
      circular['a'] = circular;
      expect(
        () => QS.encode(circular),
        throwsA(isA<RangeError>()),
      );

      final arr = ['a'];
      expect(
        () => QS.encode({'x': arr, 'y': arr}),
        isNot(throwsRangeError),
        reason: 'non-cyclic values do not throw',
      );
    });

    test('non-circular duplicated references can still work', () {
      final hourOfDay = {'function': 'hour_of_day'};
      final p1 = {
        'function': 'gte',
        'arguments': [hourOfDay, 0],
      };
      final p2 = {
        'function': 'lte',
        'arguments': [hourOfDay, 23],
      };

      expect(
        QS.encode(
          {
            'filters': {
              r'$and': [p1, p2],
            },
          },
          const EncodeOptions(encodeValuesOnly: true),
        ),
        equals(
          [
            r'filters[$and][0][function]=',
            r'gte&filters[$and][0][arguments][0][function]=',
            r'hour_of_day&filters[$and][0][arguments][1]=',
            r'0&filters[$and][1][function]=',
            r'lte&filters[$and][1][arguments][0][function]=',
            r'hour_of_day&filters[$and][1][arguments][1]=23',
          ].join(),
        ),
      );
    });

    test('can disable uri encoding', () {
      expect(
        QS.encode({'a': 'b'}, const EncodeOptions(encode: false)),
        equals('a=b'),
      );
      expect(
        QS.encode(
          {
            'a': {'b': 'c'},
          },
          const EncodeOptions(encode: false),
        ),
        equals('a[b]=c'),
      );
      expect(
        QS.encode(
          {'a': 'b', 'c': null},
          const EncodeOptions(
            strictNullHandling: true,
            encode: false,
          ),
        ),
        equals('a=b&c'),
      );
    });

    test('can sort the keys', () {
      int sort(dynamic a, dynamic b) => a.toString().compareTo(b.toString());

      expect(
        QS.encode(
          {'a': 'c', 'z': 'y', 'b': 'f'},
          EncodeOptions(sort: sort),
        ),
        equals('a=c&b=f&z=y'),
      );
      expect(
        QS.encode(
          {
            'a': 'c',
            'z': {'j': 'a', 'i': 'b'},
            'b': 'f',
          },
          EncodeOptions(sort: sort),
        ),
        equals('a=c&b=f&z%5Bi%5D=b&z%5Bj%5D=a'),
      );
    });

    test('can sort the keys at depth 3 or more too', () {
      int sort(dynamic a, dynamic b) => a.toString().compareTo(b.toString());

      expect(
        QS.encode(
          {
            'a': 'a',
            'z': {
              'zj': {'zjb': 'zjb', 'zja': 'zja'},
              'zi': {'zib': 'zib', 'zia': 'zia'},
            },
            'b': 'b',
          },
          EncodeOptions(
            sort: sort,
            encode: false,
          ),
        ),
        equals(
          'a=a&b=b&z[zi][zia]=zia&z[zi][zib]=zib&z[zj][zja]=zja&z[zj][zjb]=zjb',
        ),
      );
      expect(
        QS.encode(
          {
            'a': 'a',
            'z': {
              'zj': {'zjb': 'zjb', 'zja': 'zja'},
              'zi': {'zib': 'zib', 'zia': 'zia'},
            },
            'b': 'b',
          },
          const EncodeOptions(encode: false),
        ),
        equals(
          'a=a&z[zj][zjb]=zjb&z[zj][zja]=zja&z[zi][zib]=zib&z[zi][zia]=zia&b=b',
        ),
      );
    });

    test('serializeDate option', () {
      final date = DateTime.now();
      expect(
        QS.encode({'a': date}),
        equals(
          'a=${date.toIso8601String().replaceAll(':', '%3A')}',
        ),
      );

      final specificDate = DateTime.fromMillisecondsSinceEpoch(6);
      expect(
        QS.encode(
          {'a': specificDate},
          EncodeOptions(
            serializeDate: (DateTime d) =>
                (d.millisecondsSinceEpoch * 7).toString(),
          ),
        ),
        equals('a=42'),
        reason: 'custom serializeDate function called',
      );

      expect(
        QS.encode(
          {
            'a': [date],
          },
          EncodeOptions(
            serializeDate: (DateTime d) => d.millisecondsSinceEpoch.toString(),
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a=${date.millisecondsSinceEpoch}'),
        reason: 'works with listFormat comma',
      );
      expect(
        QS.encode(
          {
            'a': [date],
          },
          EncodeOptions(
            serializeDate: (DateTime d) => d.millisecondsSinceEpoch.toString(),
            listFormat: ListFormat.comma,
            commaRoundTrip: true,
          ),
        ),
        equals('a%5B%5D=${date.millisecondsSinceEpoch}'),
        reason: 'works with listFormat comma',
      );
    });

    test('RFC 1738 serialization', () {
      expect(
        QS.encode(
          {'a': 'b c'},
          const EncodeOptions(
            format: Format.rfc1738,
          ),
        ),
        equals('a=b+c'),
      );
      expect(
        QS.encode(
          {'a b': 'c d'},
          const EncodeOptions(format: Format.rfc1738),
        ),
        equals('a+b=c+d'),
      );
      expect(
        QS.encode(
          {'a b': StringBuffer('a b')},
          const EncodeOptions(format: Format.rfc1738),
        ),
        equals('a+b=a+b'),
      );

      expect(
        QS.encode(
          {'foo(ref)': 'bar'},
          const EncodeOptions(format: Format.rfc1738),
        ),
        equals('foo(ref)=bar'),
      );
    });

    test('RFC 3986 spaces serialization', () {
      expect(
        QS.encode(
          {'a': 'b c'},
          const EncodeOptions(
            format: Format.rfc3986,
          ),
        ),
        equals('a=b%20c'),
      );
      expect(
        QS.encode(
          {'a b': 'c d'},
          const EncodeOptions(format: Format.rfc3986),
        ),
        equals('a%20b=c%20d'),
      );
      expect(
        QS.encode(
          {'a b': StringBuffer('a b')},
          const EncodeOptions(format: Format.rfc3986),
        ),
        equals('a%20b=a%20b'),
      );
    });

    test('Backward compatibility to RFC 3986', () {
      expect(QS.encode({'a': 'b c'}), equals('a=b%20c'));
      expect(QS.encode({'a b': StringBuffer('a b')}), equals('a%20b=a%20b'));
    });

    test('encodeValuesOnly', () {
      expect(
        QS.encode(
          {
            'a': 'b',
            'c': ['d', 'e=f'],
            'f': [
              ['g'],
              ['h'],
            ],
          },
          const EncodeOptions(encodeValuesOnly: true),
        ),
        equals('a=b&c[0]=d&c[1]=e%3Df&f[0][0]=g&f[1][0]=h'),
      );
      expect(
        QS.encode({
          'a': 'b',
          'c': ['d', 'e'],
          'f': [
            ['g'],
            ['h'],
          ],
        }),
        equals('a=b&c%5B0%5D=d&c%5B1%5D=e&f%5B0%5D%5B0%5D=g&f%5B1%5D%5B0%5D=h'),
      );
    });

    test('encodeValuesOnly - strictNullHandling', () {
      expect(
        QS.encode(
          {
            'a': {'b': null},
          },
          const EncodeOptions(
            encodeValuesOnly: true,
            strictNullHandling: true,
          ),
        ),
        equals('a[b]'),
      );
    });

    test('respects a charset of iso-8859-1', () {
      expect(
        QS.encode(
          {'æ': 'æ'},
          const EncodeOptions(charset: latin1),
        ),
        equals('%E6=%E6'),
      );
    });

    test(
      'encodes unrepresentable chars as numeric entities in iso-8859-1 mode',
      () {
        expect(
          QS.encode(
            {'a': '☺'},
            const EncodeOptions(charset: latin1),
          ),
          equals('a=%26%239786%3B'),
        );
      },
    );

    test('respects an explicit charset of utf-8 (the default)', () {
      expect(
        QS.encode(
          {'a': 'æ'},
          const EncodeOptions(charset: utf8),
        ),
        equals('a=%C3%A6'),
      );
    });

    test('adds the right sentinel when instructed to and charset is utf-8', () {
      expect(
        QS.encode(
          {'a': 'æ'},
          const EncodeOptions(
            charsetSentinel: true,
            charset: utf8,
          ),
        ),
        equals('utf8=%E2%9C%93&a=%C3%A6'),
      );
    });

    test('adds the right sentinel when instructed to and charset is iso88591',
        () {
      expect(
        QS.encode(
          {'a': 'æ'},
          const EncodeOptions(
            charsetSentinel: true,
            charset: latin1,
          ),
        ),
        equals('utf8=%26%2310003%3B&a=%E6'),
      );
    });

    test('strictNullHandling works with null serializeDate', () {
      expect(
        QS.encode(
          {'key': DateTime.now()},
          EncodeOptions(
            strictNullHandling: true,
            serializeDate: (DateTime dateTime) => null,
          ),
        ),
        equals('key'),
      );
    });

    test('objects inside arrays', () {
      final obj = {
        'a': {
          'b': {'c': 'd', 'e': 'f'},
        },
      };
      final withArray = {
        'a': {
          'b': [
            {'c': 'd', 'e': 'f'},
          ],
        },
      };

      expect(
        QS.encode(obj, const EncodeOptions(encode: false)),
        equals('a[b][c]=d&a[b][e]=f'),
        reason: 'no array, no listFormat',
      );
      expect(
        QS.encode(
          obj,
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[b][c]=d&a[b][e]=f'),
        reason: 'no array, bracket',
      );
      expect(
        QS.encode(
          obj,
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a[b][c]=d&a[b][e]=f'),
        reason: 'no array, indices',
      );
      expect(
        QS.encode(
          obj,
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.comma,
          ),
        ),
        equals('a[b][c]=d&a[b][e]=f'),
        reason: 'no array, comma',
      );

      expect(
        QS.encode(
          withArray,
          const EncodeOptions(encode: false),
        ),
        equals('a[b][0][c]=d&a[b][0][e]=f'),
        reason: 'array, no listFormat',
      );
      expect(
        QS.encode(
          withArray,
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.brackets,
          ),
        ),
        equals('a[b][][c]=d&a[b][][e]=f'),
        reason: 'array, bracket',
      );
      expect(
        QS.encode(
          withArray,
          const EncodeOptions(
            encode: false,
            listFormat: ListFormat.indices,
          ),
        ),
        equals('a[b][0][c]=d&a[b][0][e]=f'),
        reason: 'array, indices',
      );
    });

    test('edge case with object/arrays', () {
      expect(
        QS.encode(
          {
            '': {
              '': [2, 3],
            },
          },
          const EncodeOptions(encode: false),
        ),
        equals('[][0]=2&[][1]=3'),
      );
      expect(
        QS.encode(
          {
            '': {
              '': [2, 3],
              'a': 2,
            },
          },
          const EncodeOptions(encode: false),
        ),
        equals('[][0]=2&[][1]=3&[a]=2'),
      );
    });
  });
}
