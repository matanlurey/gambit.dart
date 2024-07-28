/// Simulate and test odds-based mechanics such as dice rolls and more.
///
/// Gambit provides two main-types: [Distribution] and [FixedRandom].
///
/// ## Distributions
///
/// A _distriction_, or `Distribution<T>`, is a type that can be used to create
/// a random instance of `T`, given an instance of [Random]. The main property
/// of distributions are that they are:
///
/// - Immutable (once created, the distribution does not change)
/// - Deterministic (given a fixed random instance)
/// - A standard interface
///
/// For example, a [Dice] is a `Distribution<SingleDiceResult>`. Here is a [d6]:
///
/// ```dart
/// import 'package:gambit/gambit.dart';
///
/// void main() {
///   // Gambit re-exports the 'Random' class from 'dart:math'.
///   final random = Random();
///
///   // A six-sided die.
///   print(d6.sample(random)); // 1-6.
/// }
/// ```
///
/// Or, the [alphanumeric] distribution, which returns a random alphanumeric
/// string:
///
/// ```dart
/// import 'package:gambit/gambit.dart';
///
/// void main() {
///   final random = Random();
///
///   // Random alphanumeric string of 10 characters.
///   print(random.nextString(alphanumeric, 10));
/// }
/// ```
///
/// Additional built-in distributions include _weighted distributions_:
///
/// ```dart
/// import 'package:gambit/gambit.dart';
///
/// void main() {
///   final random = Random();
///
///   // 50% chance of 'a', 25% chance of 'b', 25% chance of 'c'.
///   final choices = ['a', 'b', 'c'];
///   final weights = Distribution.indexWeights([2, 1, 1]);
///   for (var i = 0; i < 100; i++) {
///     print(weights.sample(random));
///   }
/// }
/// ```
///
/// ## Testable RNGs
///
/// The [FixedRandom] class provides a way to create deterministic random
/// instances. This is useful for testing code that uses random values.
///
/// ```dart
/// import 'package:gambit/gambit.dart';
///
/// void main() {
///   final random = FixedRandom.normal(3);
/// }
/// ```
library;

import 'dart:typed_data';

// TODO: Use @docImport instead.
import 'package:gambit/gambit.dart';
import 'package:meta/meta.dart';

export 'dart:math' show Random;
export 'src/dice.dart';

/// An alternative to [Random] that allows for deterministic testing.
///
/// Each constructor stores a fixed sequence of random values from 0.0,
/// inclusive, to 1.0, exclusive. The sequence is used to generate random values
/// in the same order as they were provided.
///
/// See [FixedRandom.repeat] and [FixedRandom.terminal] for creating instances.
abstract final class FixedRandom implements Random {
  /// Returns a random instance that always throws.
  ///
  /// This instance is useful for testing code that should never use random
  /// values.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = FixedRandom.never();
  /// try {
  ///   random.nextDouble();
  /// } catch (e) {
  ///   print(e);
  /// }
  /// ```
  const factory FixedRandom.never() = _NeverFixedRandom;

  /// Returns a random instance that expects to generate [count] values.
  ///
  /// The values are generated in order from 0.0 to 1.0 to represent a normal
  /// distribution, such to test that expected random samples are generated.
  ///
  /// If [terminal] is `true`, the random instance will throw once all values
  /// have been used. Otherwise, the values will repeat indefinitely.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = FixedRandom.normal(3);
  /// print(random.nextDouble()); // 0.0
  /// print(random.nextDouble()); // 0.5
  /// print(random.nextDouble()); // 1.0
  /// ```
  factory FixedRandom.normal(int count, {bool terminal = false}) {
    final values = Iterable.generate(count, (i) => i / count);
    return terminal ? FixedRandom.terminal(values) : FixedRandom.repeat(values);
  }

  /// Returns a random instance that repeats the given [values] indefinitely.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = FixedRandom.repeat([0.1, 0.2, 0.3]);
  /// print(random.nextDouble()); // 0.1
  /// print(random.nextDouble()); // 0.2
  /// print(random.nextDouble()); // 0.3
  /// print(random.nextDouble()); // 0.1
  /// ```
  factory FixedRandom.repeat(Iterable<double> values) {
    return _RepeatingFixedRandom(values);
  }

  /// Returns a random instance that uses the given [values] in order.
  ///
  /// Once all values have been used, subsequent calls to [nextDouble] throw.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = FixedRandom.terminal([0.1, 0.2, 0.3]);
  /// print(random.nextDouble()); // 0.1
  /// print(random.nextDouble()); // 0.2
  /// print(random.nextDouble()); // 0.3
  ///
  /// try {
  ///   random.nextDouble();
  /// } catch (e) {
  ///   print(e); // No more values.
  /// }
  /// ```
  factory FixedRandom.terminal(Iterable<double> values) {
    return _TerminalFixedRandom(values);
  }

  FixedRandom._(Iterable<double> values) : _values = List.of(values) {
    if (_values.isEmpty) {
      throw ArgumentError.value(
        values,
        'values',
        'Cannot be empty.',
      );
    }
  }

  const FixedRandom._unchecked(this._values);
  final List<double> _values;

  @override
  int nextInt(int max) => max == 0 ? 0 : (nextDouble() * max).floor();

  @override
  bool nextBool() => nextInt(2) == 0;
}

final class _NeverFixedRandom extends FixedRandom {
  const _NeverFixedRandom() : super._unchecked(const []);

  @override
  double nextDouble() {
    throw StateError('No values.');
  }
}

final class _TerminalFixedRandom extends FixedRandom {
  _TerminalFixedRandom(super.values) : super._();

  @override
  double nextDouble() {
    if (_values.isEmpty) {
      throw StateError('No more values.');
    }
    return _values.removeAt(0);
  }
}

final class _RepeatingFixedRandom extends FixedRandom {
  _RepeatingFixedRandom(super.values) : super._();

  var _index = 0;

  @override
  double nextDouble() {
    if (_index == _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}

/// Utilities for random number generation.
///
/// See also [Distribution] for creating custom random distributions.
///
/// ## Example
///
/// Given a [Random] instance, generate a wider range of random values:
///
/// ```dart
/// final random = Random();
/// print(random.nextInt(100)); // 0-99.
/// print(random.nextString(alphanumeric, 10)); // Random alphanumeric string.
/// ```
extension RandomExtension on Random {
  /// Returns a random sampled element from the given [distribution].
  ///
  /// This method is equivalent to calling `distribution(this)`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = Random();
  /// print(random.next(alphanumeric));
  /// ```
  T next<T>(Distribution<T> distribution) => distribution.sample(this);

  /// Returns a random string of [length] using the given [distribution].
  ///
  /// It is assumed that the distribution returns valid character codes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = Random();
  /// print(random.nextString(alphanumeric, 10));
  /// ```
  String nextString(Distribution<int> distribution, int length) {
    RangeError.checkNotNegative(length, 'length');
    if (length == 0) {
      return '';
    }

    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = distribution.sample(this);
    }
    return String.fromCharCodes(bytes);
  }
}

/// Types that can be used to create a random instance of [T].
///
/// Implementations should be immutable.
@immutable
abstract class Distribution<T> {
  // ignore: public_member_api_docs
  const Distribution();

  /// Returns a distribution that always returns the given [value].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = Random();
  /// final always42 = Distribution.alwaysReturn(42);
  /// print(random.next(always42)); // 42
  /// ```
  const factory Distribution.alwaysReturn(T value) = _ConstantDistribution;

  /// Returns a distribution that returns a random character from a string.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = Random();
  /// print(random.next(Distribution.fromString('abc'))); // 'a', 'b', or 'c'.
  /// ```
  static Distribution<int> fromString(String string) {
    return _StringDistribution(string);
  }

  /// Returns a distribution that returns a random element from an iterable.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = Random();
  /// print(random.next(Distribution.fromElements([1, 2, 3]))); // 1, 2, or 3.
  /// ```
  static Distribution<T> fromElements<T>(Iterable<T> elements) {
    return _ListDistribution(List.of(elements));
  }

  /// Returns a distribution that delegates to the given [generator] function.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = Random();
  /// final generator = (random) => random.nextInt(100);
  /// print(random.next(Distribution.fromGenerator(generator))); // 0-99.
  /// ```
  static Distribution<T> fromGenerator<T>(T Function(Random random) generator) {
    return _GeneratorDistribution(generator);
  }

  /// Returns a distribution using weighted sampling of discrete items.
  ///
  /// Sampling the resulting distribution returns the index of a randomly
  /// selected element from [weights]. The chance of a given element being
  /// selected is proportional to the value of the element.
  ///
  /// Weights must:
  /// - Be non-negative;
  /// - Have at least one element;
  /// - Have a sum greater than zero.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final random = Random();
  /// final choices = ['a', 'b', 'c'];
  /// final weights = Distribution.fromWeights([2, 1, 1]);
  /// for (var i = 0; i < 100; i++) {
  ///   // 50% chance of 'a', 25% chance of 'b', 25% chance of 'c'.
  ///   print(choices[random.next(weights)]);
  /// }
  /// ```
  ///
  /// ## Performance
  ///
  /// Sampling time is `O(log n)`, where `n` is the number of weights.
  static Distribution<int> indexWeights(Iterable<num> weights) {
    return _WeightedIndexDistribution(weights);
  }

  /// Returns a random instance of [T] using the given [random].
  T sample(Random random);
}

final class _ConstantDistribution<T> extends Distribution<T> {
  final T _value;

  const _ConstantDistribution(this._value);

  @override
  T sample(Random _) => _value;
}

final class _StringDistribution extends Distribution<int> {
  final String _string;

  _StringDistribution(this._string);

  @override
  int sample(Random random) {
    return _string.codeUnitAt(random.nextInt(_string.length));
  }
}

final class _ListDistribution<T> extends Distribution<T> {
  final List<T> _list;

  const _ListDistribution(this._list);

  @override
  T sample(Random random) => _list[random.nextInt(_list.length)];
}

final class _GeneratorDistribution<T> extends Distribution<T> {
  final T Function(Random random) _generator;

  const _GeneratorDistribution(this._generator);

  @override
  T sample(Random random) => _generator(random);
}

final class _WeightedIndexDistribution extends Distribution<int> {
  factory _WeightedIndexDistribution(Iterable<num> weights) {
    final total = weights.fold(0.0, (a, b) {
      if (b < 0) {
        throw ArgumentError.value(
          b,
          'weights',
          'Must be non-negative.',
        );
      }
      return a + b;
    });
    if (total == 0) {
      throw ArgumentError.value(
        weights,
        'weights',
        'Sum of weights must be greater than zero.',
      );
    }
    final normalized = List.of(weights.map((e) => e / total));
    return _WeightedIndexDistribution._(normalized);
  }

  final List<double> _weights;

  const _WeightedIndexDistribution._(this._weights);

  @override
  int sample(Random random) {
    final value = random.nextDouble();
    var sum = 0.0;
    for (var i = 0; i < _weights.length - 1; i++) {
      sum += _weights[i];
      if (value < sum) {
        return i;
      }
    }
    return _weights.length - 1;
  }
}

const _alphaLower = 'abcdefghijklmnopqrstuvwxyz';
const _alphaUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _numeric = '0123456789';
const _alphaNumeric = '$_alphaLower$_alphaUpper$_numeric';

/// Samples a random alphanumeric character (`a-z`, `A-Z`, `0-9`).
///
/// ## Example
///
/// ```dart
/// final random = Random();
/// print(random.next(alphanumeric)); // 'a', or any other valid character.
/// ```
///
/// [RandomExtension.nextString] is an easier way to generate random strings:
///
/// ```dart
/// final random = Random();
/// print(random.nextString(alpahnumeric));
/// ```
final alphanumeric = Distribution.fromString(_alphaNumeric);
