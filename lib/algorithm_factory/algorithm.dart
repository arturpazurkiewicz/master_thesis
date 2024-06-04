import '../../model/recipe_full.dart';

abstract class Algorithm {
  Set<int> calculate(Set<int> input, DateTime day);

  void preprocess(List<RecipeFull> transactions);

  int? productWillBeVisibleAfter(Set<int> input, int product, DateTime day) {
    return null;
  }
}
