import 'package:checks/checks.dart';
import 'package:gambit/gambit.dart';
import 'package:test/test.dart' show group, test;

void main() {
  group('FixedRandom', () {
    test('never always throws', () {
      check(() => FixedRandom.never().nextDouble()).throws<StateError>();
    });

    test('requires non-emtpy values', () {
      check(() => FixedRandom.terminal([])).throws<ArgumentError>();
      check(() => FixedRandom.repeat([])).throws<ArgumentError>();
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

    test('also works with integers and booleans', () {
      final random = FixedRandom.normal(4);
      check(random.nextInt(4)).equals(0);
      check(random.nextInt(4)).equals(1);
      check(random.nextInt(4)).equals(2);
      check(random.nextInt(4)).equals(3);

      check(random.nextBool()).isTrue();
      check(random.nextBool()).isTrue();
      check(random.nextBool()).isFalse();
      check(random.nextBool()).isFalse();
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

  group('Dice', () {
    test('use an existing dice', () {
      final random = FixedRandom.normal(3);
      check(d6.sample(random).toString()).equals('1');
      check(d6.sample(random).toString(verbose: true)).equals('3 (1d6)');
    });

    test('create a custom dice', () {
      final random = FixedRandom.normal(3);
      final $3d7 = Dice(7) * 3;
      check('${$3d7}').equals('3d7');
      check($3d7).equals(MultipleDice(3, Dice(7)));
      check($3d7)
          .has((d) => d.hashCode, 'hashCode')
          .equals(MultipleDice(3, Dice(7)).hashCode);
      check($3d7.sample(random).toString()).equals('9');
      check($3d7.sample(random).toString(verbose: true)).equals('9 (3d7)');
    });

    test('dice pools must be at least 1', () {
      check(() => Dice(6) * 0).throws<ArgumentError>();
    });

    test('require dice to have at least 1 side', () {
      check(() => Dice(0)).throws<ArgumentError>();
    });

    test('dice implement == and hashCode', () {
      check(d6).equals(Dice(6));
      check(d6).has((d) => d.hashCode, 'hashCode').equals(Dice(6).hashCode);
    });
  });
}
