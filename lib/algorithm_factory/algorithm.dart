import 'package:biedronka_extractor/algorithm_factory/preprocessed_algorithm.dart';
import 'package:biedronka_extractor/algorithm_factory/unprocessed_algorithm.dart';

abstract class Algorithm implements PreprocessedAlgorithm, UnprocessedAlgorithm {
  int? productWillBeVisibleAfter(Set<int> input, int product, DateTime day) {
    return null;
  }
}
