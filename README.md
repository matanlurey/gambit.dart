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

To run the tests, run:

```shell
dart test
```

To check code coverage locally, run:

```shell
dart pub global activate -sgit https://github.com/matanlurey/chore.dart.git --git-ref=8b252e7
chore coverage
```

To preview `dartdoc` output locally, run:

```shell
chore dartdoc
```
