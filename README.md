# Gambit

Simulate odds-based mechanics such as dice rolls, card draws, and slot machines.

[![Github Actions](https://github.com/matanlurey/gambit/actions/workflows/check.yaml/badge.svg)](https://github.com/matanlurey/gambit/actions/workflows/check.yaml)
[![Coverage Status](https://coveralls.io/repos/github/matanlurey/gambit/badge.svg?branch=main)](https://coveralls.io/github/matanlurey/gambit?branch=main)

## Usage

```dart
import 'package:gambit/gambit.dart';
```

## Features

- Extensions on `Random` and a `Distribution` interface for custom mechanics:
- **Dice**: Roll and simulate dice of any size;

## Contributing

Gambit is a tiny, focused package. Within that scope, we're happy to accept
contributions. If you have a feature you'd like to see, feel free to
[file an issue](https://github.com/matanlurey/gambit/issues/new) or
[fork and open a pull request](https://github.com/matanlurey/gambit/fork).

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
