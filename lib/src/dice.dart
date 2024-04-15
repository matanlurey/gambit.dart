import 'dart:math';

import 'package:gambit/gambit.dart';
import 'package:meta/meta.dart';

/// A 4-sided die.
const d4 = Dice._(4);

/// A 6-sided die.
const d6 = Dice._(6);

/// An 8-sided die.
const d8 = Dice._(8);

/// A 10-sided die.
const d10 = Dice._(10);

/// A 12-sided die.
const d12 = Dice._(12);

/// A 20-sided die.
const d20 = Dice._(20);

/// A 100-sided die.
const d100 = Dice._(100);

/// A single die with a fixed number of [sides].
///
/// See also:
/// - [d4]
/// - [d6]
/// - [d8]
/// - [d10]
/// - [d12]
/// - [d20]
/// - [d100]
///
/// ## Equality
///
/// Two dice are equal if they have the same number of sides:
///
/// ```dart
/// print(Dice(6) == Dice(6)); // true
/// print(Dice(6) == Dice(20)); // false
/// ```
///
/// ## Example
///
/// ```dart
/// final d6 = Dice(6);
/// print(d6.sample(Random()));
/// ```
@immutable
final class Dice extends Distribution<SingleDiceResult> {
  /// Creates a die with [sides] number of faces.
  factory Dice(int sides) {
    if (sides < 1) {
      throw ArgumentError.value(
        sides,
        'sides',
        'Must be greater than 0.',
      );
    }
    return Dice._(sides);
  }

  const Dice._(this.sides);

  /// Number of faces on the die.
  ///
  /// Must be greater than 0.
  final int sides;

  /// Creates a pool of [count] dice with [sides] number of faces.
  ///
  /// Count must be greater than 0.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pool = Dice(6) * 3;
  /// print(pool); // 3d6
  /// ```
  MultipleDice operator *(int count) => MultipleDice(count, this);

  @override
  bool operator ==(Object other) => other is Dice && sides == other.sides;

  @override
  int get hashCode => sides.hashCode;

  @override
  SingleDiceResult sample(Random random) {
    return SingleDiceResult(this, random.nextInt(sides) + 1);
  }

  @override
  String toString() => 'd$sides';
}

/// Result of a dice roll.
@immutable
sealed class DiceResult {
  /// Value of the dice roll(s).
  ///
  /// Depending on the context, this can be the direct result of a single die
  /// roll, the sum of multiple dice rolls, or any other mechanism (such as
  /// modifiers, roll with advantage, etc).
  int get value;

  @mustBeOverridden
  @override
  String toString({bool verbose = false});
}

/// Result of a single dice roll.
final class SingleDiceResult extends DiceResult {
  /// Creates a result of a single dice roll.
  SingleDiceResult(this.dice, this.value) {
    RangeError.checkValueInInterval(value, 1, dice.sides, 'value');
  }

  /// Which dice was rolled.
  final Dice dice;

  /// Value of the dice roll.
  ///
  /// A number between 1 and [Dice.sides].
  @override
  final int value;

  @override
  String toString({bool verbose = false}) {
    if (verbose) {
      return '$value (1$dice)';
    }
    return '$value';
  }
}

/// Pool of multiple dice.
@immutable
final class MultipleDice extends Distribution<MultipleDiceResult> {
  /// Creates a pool of [count] dice with [sides] number of faces.
  MultipleDice(this.count, this.dice) {
    if (count < 1) {
      throw ArgumentError.value(
        count,
        'count',
        'Must be greater than 0.',
      );
    }
  }

  /// Number of dice in the pool.
  ///
  /// Must be greater than 0.
  final int count;

  /// Which dice are in the pool.
  final Dice dice;

  @override
  MultipleDiceResult sample(Random random) {
    return MultipleDiceResult(
      dice,
      List.generate(count, (_) => dice.sample(random).value),
    );
  }
}

/// Result of a pool of multiple dice.
@immutable
final class MultipleDiceResult extends DiceResult {
  /// Creates a result of a pool of multiple dice.
  MultipleDiceResult(
    this.dice,
    Iterable<int> results,
  ) : results = List.unmodifiable(results);

  /// Dice that were rolled.
  final Dice dice;

  /// Results of individual dice rolls.
  ///
  /// The length of this list is equal to the number of dice in the pool, which
  /// is always at least 1, and the value of each element is between 1 and
  /// [Dice.sides].
  ///
  /// The list is unmodifiable.
  final List<int> results;

  /// Sum of all individiaul dice [results].
  @override
  int get value => results.fold<int>(0, (sum, result) => sum + result);

  @override
  String toString({bool verbose = false}) {
    if (!verbose) {
      return '$value';
    }
    return '$value (${results.length}$dice)';
  }
}
