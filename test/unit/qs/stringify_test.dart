import 'package:dart_api_query/src/qs/qs.dart';
import 'package:dart_api_query/src/qs/stringify_options.dart';
import 'package:dart_api_query/src/qs/utils.dart';
import 'package:test/test.dart';

void main() {
  group('stringify()', () {
    test('stringifies a query string object', () {
      expect(Qs.stringify({'a': 'b'}), equals('a=b'));
      expect(Qs.stringify({'a': 1}), equals('a=1'));
      expect(Qs.stringify({'a': 1, 'b': 2}), equals('a=1&b=2'));
      expect(Qs.stringify({'a': 'A_Z'}), equals('a=A_Z'));
      expect(Qs.stringify({'a': '€'}), equals('a=%E2%82%AC'));
      expect(Qs.stringify({'a': ''}), equals('a=%EE%80%80'));
      expect(Qs.stringify({'a': 'א'}), equals('a=%D7%90'));
      expect(Qs.stringify({'a': '𐐷'}), equals('a=%F0%90%90%B7'));
    });

    test('stringifies falsy values', () {
      expect(Qs.stringify(null), equals(''));
      expect(
        Qs.stringify(null, opts: StringifyOptions(strictNullHandling: true)),
        equals(''),
      );
      expect(Qs.stringify(false), equals(''));
      expect(Qs.stringify(0), equals(''));
    });

    test('stringifies big ints', () {
      final three = BigInt.from(3);
      dynamic encodeWithN(
        dynamic value,
        Charset? charset,
        RfcFormat? format,
      ) {
        final result = Utils.encode(value.toString(), charset, null);
        return value is BigInt ? '${result}n' : result;
      }

      expect(Qs.stringify(three), equals(''));
      expect(Qs.stringify([three]), equals('0=3'));
      expect(
        Qs.stringify([three], opts: StringifyOptions(encoder: encodeWithN)),
        equals('0=3n'),
      );
      expect(Qs.stringify({'a': three}), equals('a=3'));
      expect(
        Qs.stringify(
          {'a': three},
          opts: StringifyOptions(encoder: encodeWithN),
        ),
        equals('a=3n'),
      );
      expect(
        Qs.stringify(
          {
            'a': [three]
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[]=3'),
      );
      expect(
        Qs.stringify(
          {
            'a': [three]
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            encoder: encodeWithN,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[]=3n'),
      );
    });

    test('adds query prefix', () {
      expect(
        Qs.stringify({'a': 'b'}, opts: StringifyOptions(addQueryPrefix: true)),
        equals('?a=b'),
      );
    });

    test('with query prefix, outputs blank string given an empty object', () {
      expect(
        Qs.stringify(
          <dynamic, dynamic>{},
          opts: StringifyOptions(addQueryPrefix: true),
        ),
        equals(''),
      );
    });

    test('stringifies nested falsy values', () {
      expect(
        Qs.stringify({
          'a': {
            'b': {'c': null}
          }
        }),
        equals('a%5Bb%5D%5Bc%5D='),
      );
      expect(
        Qs.stringify(
          {
            'a': {
              'b': {'c': null}
            }
          },
          opts: StringifyOptions(strictNullHandling: true),
        ),
        equals('a%5Bb%5D%5Bc%5D'),
      );
      expect(
        Qs.stringify({
          'a': {
            'b': {'c': false}
          }
        }),
        equals('a%5Bb%5D%5Bc%5D=false'),
      );
    });

    test('stringifies a nested object', () {
      expect(
        Qs.stringify({
          'a': {'b': 'c'}
        }),
        equals('a%5Bb%5D=c'),
      );
      expect(
        Qs.stringify({
          'a': {
            'b': {
              'c': {'d': 'e'}
            }
          }
        }),
        equals('a%5Bb%5D%5Bc%5D%5Bd%5D=e'),
      );
    });

    test('stringifies a nested object with dots notation', () {
      expect(
        Qs.stringify(
          {
            'a': {'b': 'c'}
          },
          opts: StringifyOptions(allowDots: true),
        ),
        equals('a.b=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': {
              'b': {
                'c': {'d': 'e'}
              }
            }
          },
          opts: StringifyOptions(allowDots: true),
        ),
        equals('a.b.c.d=e'),
      );
    });

    test('stringifies an array value', () {
      expect(
        Qs.stringify(
          {
            'a': ['b', 'c', 'd']
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.indices),
        ),
        equals('a%5B0%5D=b&a%5B1%5D=c&a%5B2%5D=d'),
        reason: 'indices => indices',
      );
      expect(
        Qs.stringify(
          {
            'a': ['b', 'c', 'd']
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.brackets),
        ),
        equals('a%5B%5D=b&a%5B%5D=c&a%5B%5D=d'),
        reason: 'brackets => brackets',
      );
      expect(
        Qs.stringify(
          {
            'a': ['b', 'c', 'd']
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.comma),
        ),
        equals('a=b%2Cc%2Cd'),
        reason: 'comma => comma',
      );
      expect(
        Qs.stringify({
          'a': ['b', 'c', 'd']
        }),
        equals('a%5B0%5D=b&a%5B1%5D=c&a%5B2%5D=d'),
        reason: 'default => indices',
      );
    });

    test('omits nulls when asked', () {
      expect(
        Qs.stringify(
          {'a': 'b', 'c': null},
          opts: StringifyOptions(skipNulls: true),
        ),
        equals('a=b'),
      );
    });

    test('omits nested null when asked', () {
      expect(
        Qs.stringify(
          {
            'a': {'b': 'c', 'd': null}
          },
          opts: StringifyOptions(skipNulls: true),
        ),
        equals('a%5Bb%5D=c'),
      );
    });

    test('omits array indices when asked', () {
      expect(
        Qs.stringify(
          {
            'a': ['b', 'c', 'd']
          },
          opts: StringifyOptions(indices: false),
        ),
        equals('a=b&a=c&a=d'),
      );
    });

    group('stringifies an array value with one item vs multiple items', () {
      test('non-array item', () {
        expect(
          Qs.stringify(
            {'a': 'c'},
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.indices,
            ),
          ),
          equals('a=c'),
        );
        expect(
          Qs.stringify(
            {'a': 'c'},
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.brackets,
            ),
          ),
          equals('a=c'),
        );
        expect(
          Qs.stringify(
            {'a': 'c'},
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.comma,
            ),
          ),
          equals('a=c'),
        );
        expect(
          Qs.stringify(
            {'a': 'c'},
            opts: StringifyOptions(encodeValuesOnly: true),
          ),
          equals('a=c'),
        );
      });

      test('array with a single item', () {
        expect(
          Qs.stringify(
            {
              'a': ['c']
            },
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.indices,
            ),
          ),
          equals('a[0]=c'),
        );
        expect(
          Qs.stringify(
            {
              'a': ['c']
            },
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.brackets,
            ),
          ),
          equals('a[]=c'),
        );
        expect(
          Qs.stringify(
            {
              'a': ['c']
            },
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.comma,
            ),
          ),
          equals('a=c'),
        );
        expect(
          Qs.stringify(
            {
              'a': ['c']
            },
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.comma,
              commaRoundTrip: true,
            ),
          ),
          equals('a[]=c'),
        );
        expect(
          Qs.stringify(
            {
              'a': ['c']
            },
            opts: StringifyOptions(encodeValuesOnly: true),
          ),
          equals('a[0]=c'),
        );
      });

      test('array with multiple items', () {
        expect(
          Qs.stringify(
            {
              'a': ['c', 'd']
            },
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.indices,
            ),
          ),
          equals('a[0]=c&a[1]=d'),
        );
        expect(
          Qs.stringify(
            {
              'a': ['c', 'd']
            },
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.brackets,
            ),
          ),
          equals('a[]=c&a[]=d'),
        );
        expect(
          Qs.stringify(
            {
              'a': ['c', 'd']
            },
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.comma,
            ),
          ),
          equals('a=c,d'),
        );
        expect(
          Qs.stringify(
            {
              'a': ['c', 'd']
            },
            opts: StringifyOptions(encodeValuesOnly: true),
          ),
          equals('a[0]=c&a[1]=d'),
        );
      });

      test('array with multiple items with a comma inside', () {
        expect(
          Qs.stringify(
            {
              'a': ['c,d', 'e']
            },
            opts: StringifyOptions(
              encodeValuesOnly: true,
              arrayFormat: ArrayFormat.comma,
            ),
          ),
          equals('a=c%2Cd,e'),
        );
        expect(
          Qs.stringify(
            {
              'a': ['c,d', 'e']
            },
            opts: StringifyOptions(arrayFormat: ArrayFormat.comma),
          ),
          equals('a=c%2Cd%2Ce'),
        );
      });
    });

    test('stringifies a nested array value', () {
      expect(
        Qs.stringify(
          {
            'a': {
              'b': ['c', 'd']
            }
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a[b][0]=c&a[b][1]=d'),
      );
      expect(
        Qs.stringify(
          {
            'a': {
              'b': ['c', 'd']
            }
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[b][]=c&a[b][]=d'),
      );
      expect(
        Qs.stringify(
          {
            'a': {
              'b': ['c', 'd']
            }
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a[b]=c,d'),
      );
      expect(
        Qs.stringify(
          {
            'a': {
              'b': ['c', 'd']
            }
          },
          opts: StringifyOptions(encodeValuesOnly: true),
        ),
        equals('a[b][0]=c&a[b][1]=d'),
      );
    });

    test('stringifies comma and empty array values', () {
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a[0]=,&a[1]=&a[2]=c,d%'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[]=,&a[]=&a[]=c,d%'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a=,,,c,d%'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.repeat,
          ),
        ),
        equals('a=,&a=&a=c,d%'),
      );

      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a[0]=%2C&a[1]=&a[2]=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[]=%2C&a[]=&a[]=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a=%2C,,c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.repeat,
          ),
        ),
        equals('a=%2C&a=&a=c%2Cd%25'),
      );

      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a%5B0%5D=%2C&a%5B1%5D=&a%5B2%5D=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a%5B%5D=%2C&a%5B%5D=&a%5B%5D=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: false,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a=%2C%2C%2Cc%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {
            'a': [',', '', 'c,d%']
          },
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: false,
            arrayFormat: ArrayFormat.repeat,
          ),
        ),
        equals('a=%2C&a=&a=c%2Cd%25'),
      );
    });

    test('stringifies comma and empty non-array values', () {
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a=,&b=&c=c,d%'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a=,&b=&c=c,d%'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a=,&b=&c=c,d%'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.repeat,
          ),
        ),
        equals('a=,&b=&c=c,d%'),
      );

      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.repeat,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );

      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: false,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
      expect(
        Qs.stringify(
          {'a': ',', 'b': '', 'c': 'c,d%'},
          opts: StringifyOptions(
            encode: true,
            encodeValuesOnly: false,
            arrayFormat: ArrayFormat.repeat,
          ),
        ),
        equals('a=%2C&b=&c=c%2Cd%25'),
      );
    });

    test('stringifies a nested array value with dots notation', () {
      expect(
        Qs.stringify(
          {
            'a': {
              'b': ['c', 'd']
            }
          },
          opts: StringifyOptions(
            allowDots: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a.b[0]=c&a.b[1]=d'),
        reason: 'indices: stringifies with dots + indices',
      );
      expect(
        Qs.stringify(
          {
            'a': {
              'b': ['c', 'd']
            }
          },
          opts: StringifyOptions(
            allowDots: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a.b[]=c&a.b[]=d'),
        reason: 'brackets: stringifies with dots + brackets',
      );
      expect(
        Qs.stringify(
          {
            'a': {
              'b': ['c', 'd']
            }
          },
          opts: StringifyOptions(
            allowDots: true,
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a.b=c,d'),
        reason: 'comma: stringifies with dots + comma',
      );
      expect(
        Qs.stringify(
          {
            'a': {
              'b': ['c', 'd']
            }
          },
          opts: StringifyOptions(
            allowDots: true,
            encodeValuesOnly: true,
          ),
        ),
        equals('a.b[0]=c&a.b[1]=d'),
        reason: 'default: stringifies with dots + indices',
      );
    });

    test('stringifies an object inside an array', () {
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 'c'}
            ]
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.indices),
        ),
        equals('a%5B0%5D%5Bb%5D=c'), // a[0][b]=c
        reason: 'indices => brackets',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 'c'}
            ]
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.brackets),
        ),
        equals('a%5B%5D%5Bb%5D=c'), // a[][b]=c
        reason: 'brackets => brackets',
      );
      expect(
        Qs.stringify({
          'a': [
            {'b': 'c'}
          ]
        }),
        equals('a%5B0%5D%5Bb%5D=c'),
        reason: 'default => indices',
      );

      expect(
        Qs.stringify(
          {
            'a': [
              {
                'b': {
                  'c': [1]
                }
              }
            ]
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.indices),
        ),
        equals('a%5B0%5D%5Bb%5D%5Bc%5D%5B0%5D=1'),
        reason: 'indices => indices',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {
                'b': {
                  'c': [1]
                }
              }
            ]
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.brackets),
        ),
        equals('a%5B%5D%5Bb%5D%5Bc%5D%5B%5D=1'),
        reason: 'brackets => brackets',
      );
      expect(
        Qs.stringify({
          'a': [
            {
              'b': {
                'c': [1]
              }
            }
          ]
        }),
        equals('a%5B0%5D%5Bb%5D%5Bc%5D%5B0%5D=1'),
        reason: 'default => indices',
      );
    });

    test('stringifies an array with mixed objects and primitives', () {
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 1},
              2,
              3
            ]
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a[0][b]=1&a[1]=2&a[2]=3'),
        reason: 'indices => indices',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 1},
              2,
              3
            ]
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[][b]=1&a[]=2&a[]=3'),
        reason: 'brackets => brackets',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 1},
              2,
              3
            ]
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('???'),
        reason: 'brackets => brackets',
        skip: 'TODO: figure out what this should do',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 1},
              2,
              3
            ]
          },
          opts: StringifyOptions(encodeValuesOnly: true),
        ),
        equals('a[0][b]=1&a[1]=2&a[2]=3'),
        reason: 'default => indices',
      );
    });

    test('stringifies an object inside an array with dots notation', () {
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 'c'}
            ]
          },
          opts: StringifyOptions(
            allowDots: true,
            encode: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a[0].b=c'),
        reason: 'indices => indices',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 'c'}
            ]
          },
          opts: StringifyOptions(
            allowDots: true,
            encode: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[].b=c'),
        reason: 'brackets => brackets',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {'b': 'c'}
            ]
          },
          opts: StringifyOptions(
            allowDots: true,
            encode: false,
          ),
        ),
        equals('a[0].b=c'),
        reason: 'default => indices',
      );

      expect(
        Qs.stringify(
          {
            'a': [
              {
                'b': {
                  'c': [1]
                }
              }
            ]
          },
          opts: StringifyOptions(
            allowDots: true,
            encode: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a[0].b.c[0]=1'),
        reason: 'indices => indices',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {
                'b': {
                  'c': [1]
                }
              }
            ]
          },
          opts: StringifyOptions(
            allowDots: true,
            encode: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[].b.c[]=1'),
        reason: 'brackets => brackets',
      );
      expect(
        Qs.stringify(
          {
            'a': [
              {
                'b': {
                  'c': [1]
                }
              }
            ]
          },
          opts: StringifyOptions(
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
        Qs.stringify(
          {
            'a': [
              {'b': 'c'}
            ]
          },
          opts: StringifyOptions(indices: false),
        ),
        equals('a%5Bb%5D=c'),
      );
    });

    test('uses indices notation for arrays when indices=true', () {
      expect(
        Qs.stringify(
          {
            'a': ['b', 'c']
          },
          opts: StringifyOptions(indices: true),
        ),
        equals('a%5B0%5D=b&a%5B1%5D=c'),
      );
    });

    test('uses indices notation for arrays when no arrayFormat is specified',
        () {
      expect(
        Qs.stringify({
          'a': ['b', 'c']
        }),
        equals('a%5B0%5D=b&a%5B1%5D=c'),
      );
    });

    test('uses indices notation for arrays when arrayFormat=indices', () {
      expect(
        Qs.stringify(
          {
            'a': ['b', 'c']
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.indices),
        ),
        equals('a%5B0%5D=b&a%5B1%5D=c'),
      );
    });

    test('uses repeat notation for arrays when no arrayFormat=repeat', () {
      expect(
        Qs.stringify(
          {
            'a': ['b', 'c']
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.repeat),
        ),
        equals('a=b&a=c'),
      );
    });

    test('uses brackets notation for arrays when no arrayFormat=brackets', () {
      expect(
        Qs.stringify(
          {
            'a': ['b', 'c']
          },
          opts: StringifyOptions(arrayFormat: ArrayFormat.brackets),
        ),
        equals('a%5B%5D=b&a%5B%5D=c'),
      );
    });

    test('stringifies a complicated object', () {
      expect(
        Qs.stringify({
          'a': {'b': 'c', 'd': 'e'}
        }),
        equals('a%5Bb%5D=c&a%5Bd%5D=e'),
      );
    });

    test('stringifies an empty value', () {
      expect(Qs.stringify({'a': ''}), equals('a='));
      expect(
        Qs.stringify(
          {'a': null},
          opts: StringifyOptions(strictNullHandling: true),
        ),
        equals('a'),
      );

      expect(Qs.stringify({'a': '', 'b': ''}), equals('a=&b='));
      expect(
        Qs.stringify(
          {'a': null, 'b': ''},
          opts: StringifyOptions(strictNullHandling: true),
        ),
        equals('a&b='),
      );

      expect(
        Qs.stringify({
          'a': {'b': ''}
        }),
        equals('a%5Bb%5D='),
      );
      expect(
        Qs.stringify(
          {
            'a': {'b': null}
          },
          opts: StringifyOptions(strictNullHandling: true),
        ),
        equals('a%5Bb%5D'),
      );
      expect(
        Qs.stringify(
          {
            'a': {'b': null}
          },
          opts: StringifyOptions(strictNullHandling: false),
        ),
        equals('a%5Bb%5D='),
      );
    });

    test('stringifies an empty array in different arrayFormat', () {
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(encode: false),
        ),
        equals('b[0]=&c=c'),
      );
      // arrayFormat default
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('b[0]=&c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('b[]=&c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.repeat,
          ),
        ),
        equals('b=&c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('b=&c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.comma,
            commaRoundTrip: true,
          ),
        ),
        equals('b[]=&c=c'),
      );
      // with strictNullHandling
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.indices,
            strictNullHandling: true,
          ),
        ),
        equals('b[0]&c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.brackets,
            strictNullHandling: true,
          ),
        ),
        equals('b[]&c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.repeat,
            strictNullHandling: true,
          ),
        ),
        equals('b&c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.comma,
            strictNullHandling: true,
          ),
        ),
        equals('b&c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.comma,
            commaRoundTrip: true,
            strictNullHandling: true,
          ),
        ),
        equals('b[]&c=c'),
      );
      // with skipNulls
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.indices,
            skipNulls: true,
          ),
        ),
        equals('c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.brackets,
            skipNulls: true,
          ),
        ),
        equals('c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.repeat,
            skipNulls: true,
          ),
        ),
        equals('c=c'),
      );
      expect(
        Qs.stringify(
          {
            'a': <dynamic>[],
            'b': [null],
            'c': 'c'
          },
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.comma,
            skipNulls: true,
          ),
        ),
        equals('c=c'),
      );
    });

    test('returns an empty string for invalid input', () {
      expect(Qs.stringify(false), equals(''));
      expect(Qs.stringify(null), equals(''));
      expect(Qs.stringify(''), equals(''));
    });

    test('url encodes values', () {
      expect(Qs.stringify({'a': 'b c'}), equals('a=b%20c'));
    });

    test('stringifies a date', () {
      final now = DateTime.now();
      final str = 'a=${Uri.encodeComponent(now.toIso8601String())}';
      expect(Qs.stringify({'a': now}), equals(str));
    });

    test('stringifies the weird object from qs', () {
      expect(
        Qs.stringify({'my weird field': '~q1!2"\'w\$5&7/z8)?'}),
        equals('my%20weird%20field=~q1%212%22%27w%245%267%2Fz8%29%3F'),
      );
    });

    test('stringifies boolean values', () {
      expect(Qs.stringify({'a': true}), equals('a=true'));
      expect(
        Qs.stringify({
          'a': {'b': true}
        }),
        equals('a%5Bb%5D=true'),
      );
      expect(Qs.stringify({'b': false}), equals('b=false'));
      expect(
        Qs.stringify({
          'b': {'c': false}
        }),
        equals('b%5Bc%5D=false'),
      );
    });

    test('stringifies buffer values', () {
      expect(Qs.stringify({'a': StringBuffer('test')}), equals('a=test'));
      expect(
        Qs.stringify({
          'a': {'b': StringBuffer('test')}
        }),
        equals('a%5Bb%5D=test'),
      );
    });

    test('stringifies an object using an alternative delimiter', () {
      expect(
        Qs.stringify(
          {'a': 'b', 'c': 'd'},
          opts: StringifyOptions(delimiter: ';'),
        ),
        equals('a=b;c=d'),
      );
    });

    test('does not crash when parsing circular references', () {
      final a = <dynamic, dynamic>{};
      a['b'] = a;
      expect(
        () => Qs.stringify({'foo[bar]': 'baz', 'foo[baz]': a}),
        throwsA(
          predicate(
            (e) => e is RangeError && e.message == 'Cyclic object value',
          ),
        ),
      );

      final circular = <dynamic, dynamic>{'a': 'value'};
      circular['a'] = circular;
      expect(
        () => Qs.stringify(circular),
        throwsA(
          predicate(
            (e) => e is RangeError && e.message == 'Cyclic object value',
          ),
        ),
      );

      final arr = ['a'];
      expect(
        () => Qs.stringify({'x': arr, 'y': arr}),
        isNot(throwsRangeError),
        reason: 'non-cyclic values do not throw',
      );
    });

    test('non-circular duplicated references can still work', () {
      final hourOfDay = {'function': 'hour_of_day'};
      final p1 = {
        'function': 'gte',
        'arguments': [hourOfDay, 0]
      };
      final p2 = {
        'function': 'lte',
        'arguments': [hourOfDay, 23]
      };

      expect(
        Qs.stringify(
          {
            'filters': {
              r'$and': [p1, p2]
            }
          },
          opts: StringifyOptions(encodeValuesOnly: true),
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
        Qs.stringify({'a': 'b'}, opts: StringifyOptions(encode: false)),
        equals('a=b'),
      );
      expect(
        Qs.stringify(
          {
            'a': {'b': 'c'}
          },
          opts: StringifyOptions(encode: false),
        ),
        equals('a[b]=c'),
      );
      expect(
        Qs.stringify(
          {'a': 'b', 'c': null},
          opts: StringifyOptions(
            strictNullHandling: true,
            encode: false,
          ),
        ),
        equals('a=b&c'),
      );
    });

    test('can sort the keys', () {
      int sort(dynamic a, dynamic b) {
        return a.toString().compareTo(b.toString());
      }

      expect(
        Qs.stringify(
          {'a': 'c', 'z': 'y', 'b': 'f'},
          opts: StringifyOptions(sort: sort),
        ),
        equals('a=c&b=f&z=y'),
      );
      expect(
        Qs.stringify(
          {
            'a': 'c',
            'z': {'j': 'a', 'i': 'b'},
            'b': 'f'
          },
          opts: StringifyOptions(sort: sort),
        ),
        equals('a=c&b=f&z%5Bi%5D=b&z%5Bj%5D=a'),
      );
    });

    test('can sort the keys at depth 3 or more too', () {
      int sort(dynamic a, dynamic b) {
        return a.toString().compareTo(b.toString());
      }

      expect(
        Qs.stringify(
          {
            'a': 'a',
            'z': {
              'zj': {'zjb': 'zjb', 'zja': 'zja'},
              'zi': {'zib': 'zib', 'zia': 'zia'}
            },
            'b': 'b'
          },
          opts: StringifyOptions(
            sort: sort,
            encode: false,
          ),
        ),
        equals(
          'a=a&b=b&z[zi][zia]=zia&z[zi][zib]=zib&z[zj][zja]=zja&z[zj][zjb]=zjb',
        ),
      );
      expect(
        Qs.stringify(
          {
            'a': 'a',
            'z': {
              'zj': {'zjb': 'zjb', 'zja': 'zja'},
              'zi': {'zib': 'zib', 'zia': 'zia'}
            },
            'b': 'b'
          },
          opts: StringifyOptions(encode: false),
        ),
        equals(
          'a=a&z[zj][zjb]=zjb&z[zj][zja]=zja&z[zi][zib]=zib&z[zi][zia]=zia&b=b',
        ),
      );
    });

    test('serializeDate option', () {
      final date = DateTime.now();
      expect(
        Qs.stringify({'a': date}),
        equals(
          'a=${date.toIso8601String().replaceAll(':', '%3A')}',
        ),
      );

      final specificDate = DateTime.fromMillisecondsSinceEpoch(6);
      expect(
        Qs.stringify(
          {'a': specificDate},
          opts: StringifyOptions(
            serializeDate: (DateTime d) {
              return (d.millisecondsSinceEpoch * 7).toString();
            },
          ),
        ),
        equals('a=42'),
        reason: 'custom serializeDate function called',
      );

      expect(
        Qs.stringify(
          {
            'a': [date]
          },
          opts: StringifyOptions(
            serializeDate: (DateTime d) {
              return d.millisecondsSinceEpoch.toString();
            },
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a=${date.millisecondsSinceEpoch}'),
        reason: 'works with arrayFormat comma',
      );
      expect(
        Qs.stringify(
          {
            'a': [date]
          },
          opts: StringifyOptions(
            serializeDate: (DateTime d) {
              return d.millisecondsSinceEpoch.toString();
            },
            arrayFormat: ArrayFormat.comma,
            commaRoundTrip: true,
          ),
        ),
        equals('a%5B%5D=${date.millisecondsSinceEpoch}'),
        reason: 'works with arrayFormat comma',
      );
    });

    test('RFC 1738 serialization', () {
      expect(
        Qs.stringify(
          {'a': 'b c'},
          opts: StringifyOptions(
            format: RfcFormat.rfc1738,
          ),
        ),
        equals('a=b+c'),
      );
      expect(
        Qs.stringify(
          {'a b': 'c d'},
          opts: StringifyOptions(format: RfcFormat.rfc1738),
        ),
        equals('a+b=c+d'),
      );
      expect(
        Qs.stringify(
          {'a b': StringBuffer('a b')},
          opts: StringifyOptions(format: RfcFormat.rfc1738),
        ),
        equals('a+b=a+b'),
      );

      expect(
        Qs.stringify(
          {'foo(ref)': 'bar'},
          opts: StringifyOptions(format: RfcFormat.rfc1738),
        ),
        equals('foo(ref)=bar'),
      );
    });

    test('RFC 3986 spaces serialization', () {
      expect(
        Qs.stringify(
          {'a': 'b c'},
          opts: StringifyOptions(
            format: RfcFormat.rfc3986,
          ),
        ),
        equals('a=b%20c'),
      );
      expect(
        Qs.stringify(
          {'a b': 'c d'},
          opts: StringifyOptions(format: RfcFormat.rfc3986),
        ),
        equals('a%20b=c%20d'),
      );
      expect(
        Qs.stringify(
          {'a b': StringBuffer('a b')},
          opts: StringifyOptions(format: RfcFormat.rfc3986),
        ),
        equals('a%20b=a%20b'),
      );
    });

    test('Backward compatibility to RFC 3986', () {
      expect(Qs.stringify({'a': 'b c'}), equals('a=b%20c'));
      expect(Qs.stringify({'a b': StringBuffer('a b')}), equals('a%20b=a%20b'));
    });

    test('encodeValuesOnly', () {
      expect(
        Qs.stringify(
          {
            'a': 'b',
            'c': ['d', 'e=f'],
            'f': [
              ['g'],
              ['h']
            ]
          },
          opts: StringifyOptions(encodeValuesOnly: true),
        ),
        equals('a=b&c[0]=d&c[1]=e%3Df&f[0][0]=g&f[1][0]=h'),
      );
      expect(
        Qs.stringify({
          'a': 'b',
          'c': ['d', 'e'],
          'f': [
            ['g'],
            ['h']
          ]
        }),
        equals('a=b&c%5B0%5D=d&c%5B1%5D=e&f%5B0%5D%5B0%5D=g&f%5B1%5D%5B0%5D=h'),
      );
    });

    test('encodeValuesOnly - strictNullHandling', () {
      expect(
        Qs.stringify(
          {
            'a': {'b': null}
          },
          opts: StringifyOptions(
            encodeValuesOnly: true,
            strictNullHandling: true,
          ),
        ),
        equals('a[b]'),
      );
    });

    test('respects a charset of iso-8859-1', () {
      expect(
        Qs.stringify(
          {'æ': 'æ'},
          opts: StringifyOptions(charset: Charset.iso88591),
        ),
        equals('%E6=%E6'),
      );
    });

    test(
      'encodes unrepresentable chars as numeric entities in iso-8859-1 mode',
      () {
        expect(
          Qs.stringify(
            {'a': '☺'},
            opts: StringifyOptions(charset: Charset.iso88591),
          ),
          equals('a=%26%239786%3B'),
        );
      },
    );

    test('respects an explicit charset of utf-8 (the default)', () {
      expect(
        Qs.stringify(
          {'a': 'æ'},
          opts: StringifyOptions(charset: Charset.utf8),
        ),
        equals('a=%C3%A6'),
      );
    });

    test('adds the right sentinel when instructed to and charset is utf-8', () {
      expect(
        Qs.stringify(
          {'a': 'æ'},
          opts: StringifyOptions(
            charsetSentinel: true,
            charset: Charset.utf8,
          ),
        ),
        equals('utf8=%E2%9C%93&a=%C3%A6'),
      );
    });

    test('adds the right sentinel when instructed to and charset is iso88591',
        () {
      expect(
        Qs.stringify(
          {'a': 'æ'},
          opts: StringifyOptions(
            charsetSentinel: true,
            charset: Charset.iso88591,
          ),
        ),
        equals('utf8=%26%2310003%3B&a=%E6'),
      );
    });

    test('strictNullHandling works with null serializeDate', () {
      dynamic serializeDate(DateTime dateTime) {
        return null;
      }

      expect(
        Qs.stringify(
          {'key': DateTime.now()},
          opts: StringifyOptions(
            strictNullHandling: true,
            serializeDate: serializeDate,
          ),
        ),
        equals('key'),
      );
    });

    test('objects inside arrays', () {
      final obj = {
        'a': {
          'b': {'c': 'd', 'e': 'f'}
        }
      };
      final withArray = {
        'a': {
          'b': [
            {'c': 'd', 'e': 'f'}
          ]
        }
      };

      expect(
        Qs.stringify(obj, opts: StringifyOptions(encode: false)),
        equals('a[b][c]=d&a[b][e]=f'),
        reason: 'no array, no arrayFormat',
      );
      expect(
        Qs.stringify(
          obj,
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[b][c]=d&a[b][e]=f'),
        reason: 'no array, bracket',
      );
      expect(
        Qs.stringify(
          obj,
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a[b][c]=d&a[b][e]=f'),
        reason: 'no array, indices',
      );
      expect(
        Qs.stringify(
          obj,
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.comma,
          ),
        ),
        equals('a[b][c]=d&a[b][e]=f'),
        reason: 'no array, comma',
      );

      expect(
        Qs.stringify(
          withArray,
          opts: StringifyOptions(encode: false),
        ),
        equals('a[b][0][c]=d&a[b][0][e]=f'),
        reason: 'array, no arrayFormat',
      );
      expect(
        Qs.stringify(
          withArray,
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.brackets,
          ),
        ),
        equals('a[b][][c]=d&a[b][][e]=f'),
        reason: 'array, bracket',
      );
      expect(
        Qs.stringify(
          withArray,
          opts: StringifyOptions(
            encode: false,
            arrayFormat: ArrayFormat.indices,
          ),
        ),
        equals('a[b][0][c]=d&a[b][0][e]=f'),
        reason: 'array, indices',
      );
    });

    test('edge case with object/arrays', () {
      expect(
        Qs.stringify(
          {
            '': {
              '': [2, 3]
            }
          },
          opts: StringifyOptions(encode: false),
        ),
        equals('[][0]=2&[][1]=3'),
      );
      expect(
        Qs.stringify(
          {
            '': {
              '': [2, 3],
              'a': 2
            }
          },
          opts: StringifyOptions(encode: false),
        ),
        equals('[][0]=2&[][1]=3&[a]=2'),
      );
    });
  });
}
