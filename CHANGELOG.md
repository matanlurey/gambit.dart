# 0.1.0

- Initial release:

  ```dart
  import 'package:gambit/gambit.dart';

  void main() {
    final random = FixedRandom.normal(6);

    for (var i = 0; i < 6; i++) {
      print(d6.sample(random)); // 1, 2, 3, 4, 5, 6
    }
  }
  ```
