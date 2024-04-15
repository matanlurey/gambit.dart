import 'package:gambit/gambit.dart';
import 'package:test/test.dart';

// Examples are written as test cases to be checked on CI.
void main() {
  test('reproducible random numbers for testing', () {
    final random = FixedRandom.normal(3);

    final a = random.nextDouble();
    final b = random.nextDouble();
    final c = random.nextDouble();
    final d = random.nextDouble();

    expect({a, b, c}, hasLength(3));
    expect(a, d);
  });

  test('generate random strings with extensions', () {
    final random = FixedRandom.normal(10);
    expect(random.nextString(alphanumeric, 10), 'agmsyFLRX3');
  });

  test('sample from lists of elements with distributions', () {
    final random = FixedRandom.normal(3);
    final distribution = Distribution.fromElements([1, 2, 3]);
    final results = [
      random.next(distribution),
      random.next(distribution),
      random.next(distribution),
    ];

    expect(results, [1, 2, 3]);
  });

  test('sample weighted indexes', () {
    final random = FixedRandom.normal(100);
    final distribution = Distribution.indexWeights([2, 1, 1]);
    final results = [
      for (var i = 0; i < 100; i++) random.next(distribution),
    ];

    // We should observe index 0 ~twice as often as the other indexes.
    expect(results.where((i) => i == 0), hasLength(closeTo(50, 1)));
  });

  test('roll some dice', () {
    final random = FixedRandom.normal(3);
    expect(d6.sample(random).toString(verbose: true), '1 (1d6)');

    final $3d6 = d6 * 3;
    expect($3d6.sample(random).toString(verbose: true), '9 (3d6)');
  });
}
