import '../algorithm/cosine_similarity.dart';
import '../model/recipe_full.dart';
import 'algorithm.dart';

class CosineSimilarityFactory extends Algorithm {
  final int k;
  CosineSimilarity? algorithm;

  CosineSimilarityFactory(this.k);

  @override
  Set<int> calculate(Set<int> input, DateTime day) {
    var neighbours = algorithm!.findKNearestNeighbors(k, input, day);
    return algorithm!.predictProduct(neighbours, input);
  }

  @override
  void preprocess(List<RecipeFull> transactions) {
    algorithm = CosineSimilarity(transactions);
  }
}
