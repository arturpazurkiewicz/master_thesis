import 'package:biedronka_extractor/algorithm_factory/preprocessed_algorithm.dart';

import '../model/recipe_full.dart';

abstract class UnprocessedAlgorithm {
  PreprocessedAlgorithm preprocess(List<RecipeFull> transactions);
}
