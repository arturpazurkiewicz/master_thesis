import '../algorithm/knn.dart';
import '../model/recipe_full.dart';
import 'algorithm.dart';

class KNNFactory extends Algorithm {
  final int k;
  KNN? algorithm;

  KNNFactory(this.k);

  @override
  Set<int> calculate(Set<int> input, DateTime day) {
    var neighbours = algorithm!.findKNearestNeighbors(k, input, day);
    return algorithm!.predictProduct(neighbours, input);
  }

  @override
  void preprocess(List<RecipeFull> transactions) {
    algorithm = KNN(transactions);
  }
}
