import 'package:checks/checks.dart';
import 'package:gambit/gambit.dart';
import 'package:test/test.dart' show group, test;

void main() {
  group('FixedRandom', () {
    test('never always throws', () {
      check(() => FixedRandom.never().nextDouble()).throws<StateError>();
    });

    test('terminal uses pre-defined values, then throws', () {
      final random = FixedRandom.terminal([0.5, 0.75]);
      check(random.nextDouble()).equals(0.5);
      check(random.nextDouble()).equals(0.75);
      check(random.nextDouble).throws<StateError>();
    });

    test('repeat uses a pre-defined values, then repeats', () {
      final random = FixedRandom.repeat([0.5, 0.75]);
      check(random.nextDouble()).equals(0.5);
      check(random.nextDouble()).equals(0.75);
      check(random.nextDouble()).equals(0.5);
    });

    test('normal uses a normal distribution', () {
      final random = FixedRandom.normal(3);
      check(List.generate(100, (_) => random.nextInt(3)))
        ..has((l) => l.where((i) => i == 0).length, '0').isCloseTo(33, 1)
        ..has((l) => l.where((i) => i == 1).length, '1').isCloseTo(33, 1)
        ..has((l) => l.where((i) => i == 2).length, '2').isCloseTo(33, 1);
    });

    test('normal with terminal: true throws after all values are used', () {
      final random = FixedRandom.normal(3, terminal: true);
      check(random.nextInt(3)).equals(0);
      check(random.nextInt(3)).equals(1);
      check(random.nextInt(3)).equals(2);
      check(() => random.nextInt(3)).throws<StateError>();
    });
  });

  group('RandomExtension', () {
    test('next', () {
      final random = FixedRandom.terminal([0.5]);
      check(random.next(alphanumeric))
          .has(String.fromCharCode, 'String.fromCharCode')
          .equals('F');
    });

    test('nextString', () {
      final random = FixedRandom.normal(10);
      check(random.nextString(alphanumeric, 10))
        ..has((s) => s.length, 'length').equals(10)
        ..equals('agmsyFLRX3');
    });
  });

  group('Distribution', () {
    test('alwaysReturn', () {
      const random = FixedRandom.never();
      final always42 = Distribution.alwaysReturn(42);
      check(random.next(always42)).equals(42);
    });

    test('fromString', () {
      final random = FixedRandom.normal(3);
      final distribution = Distribution.fromString('abc');
      final results = [
        distribution(random),
        distribution(random),
        distribution(random),
      ].map(String.fromCharCode).toList();

      check(results).deepEquals(['a', 'b', 'c']);
    });

    test('fromElements', () {
      final random = FixedRandom.normal(3);
      final distribution = Distribution.fromElements([1, 2, 3]);
      final results = [
        random.next(distribution),
        random.next(distribution),
        random.next(distribution),
      ];

      check(results).deepEquals([1, 2, 3]);
    });

    test('fromGenerator', () {
      final random = FixedRandom.never();
      final distribution = Distribution.fromGenerator((_) => 42);
      check(random.next(distribution)).equals(42);
    });

    group('fromWeights', () {
      test('must be contain negative weights', () {
        check(() => Distribution.indexWeights([2, -1])).throws<ArgumentError>();
      });

      test('must not be empty', () {
        check(() => Distribution.indexWeights([])).throws<ArgumentError>();
      });

      test('must not equal 0', () {
        check(() => Distribution.indexWeights([0])).throws<ArgumentError>();
      });

      test('returns a uniform distribution', () {
        final random = FixedRandom.normal(100);

        // Normally this would produce, out of 0, 1, 2, about 33% of each.
        final unweighted = List.generate(100, (_) => random.nextInt(3));
        check(unweighted)
          ..has((l) => l.where((i) => i == 0).length, '0').isCloseTo(33, 1)
          ..has((l) => l.where((i) => i == 1).length, '1').isCloseTo(33, 1)
          ..has((l) => l.where((i) => i == 2).length, '2').isCloseTo(33, 1);

        // But with weights, we can skew the distribution.
        final distribution = Distribution.indexWeights([2, 1, 1]);
        final weighted = List.generate(100, (_) => random.next(distribution));
        check(weighted)
          ..has((l) => l.where((i) => i == 0).length, '0').isCloseTo(50, 0)
          ..has((l) => l.where((i) => i == 1).length, '1').isCloseTo(25, 0)
          ..has((l) => l.where((i) => i == 2).length, '2').isCloseTo(25, 0);
      });
    });
  });

  test('alphanumeric', () {
    final random = FixedRandom.normal(100);
    final pattern = RegExp(r'^[a-zA-Z0-9]{10}$');
    for (var i = 0; i < 1000; i++) {
      final string = random.nextString(alphanumeric, 10);
      check(string).has(pattern.hasMatch, 'pattern').isTrue();
    }
  });
}
