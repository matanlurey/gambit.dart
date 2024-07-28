# Gambit

Simulate and test odds-based mechanics such as dice rolls and more.

[![Pub Package](https://img.shields.io/pub/v/gambit.svg)](https://pub.dev/packages/gambit)
[![Github Actions](https://github.com/matanlurey/gambit.dart/actions/workflows/check.yaml/badge.svg)](https://github.com/matanlurey/gambit.dart/actions/workflows/check.yaml)
[![Coverage Status](https://coveralls.io/repos/github/matanlurey/gambit.dart/badge.svg?branch=main)](https://coveralls.io/github/matanlurey/gambit.dart?branch=main)
[![Dartdoc reference](https://img.shields.io/badge/dartdoc-reference-blue.svg)](https://pub.dev/documentation/gambit/latest/)

## Usage

```dart
import 'package:gambit/gambit.dart';
```

## Features

- Extensions on `Random` and a `Distribution` interface for custom mechanics;
- **Dice**: Roll and simulate dice of any size;
- **FixedRandom**: A `Random` implementation that returns a fixed value.

## Contributing

Gambit is a tiny, focused package. Within that scope, we're happy to accept
contributions. If you have a feature you'd like to see, feel free to
[file an issue](https://github.com/matanlurey/gambit.dart/issues/new) or
[fork and open a pull request](https://github.com/matanlurey/gambit.dart/fork).

### CI

This package is:

- Formatted with `dart format`.
- Checked with `dart analyze`.
- Tested with `dart test`, including with code coverage.

See [`github/workflows/check.yaml`](./.github/workflows/check.yaml) for details.

### Coverage

To view the coverage report locally (MacOS):

```shell
brew install lcov
dart run coverage:test_with_coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```
