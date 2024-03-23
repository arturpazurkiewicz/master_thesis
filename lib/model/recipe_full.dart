import 'package:biedronka_extractor/model/recipe.dart';
import 'package:biedronka_extractor/model/recipe_entry.dart';

class RecipeFull{
  final Recipe recipe;
  final List<RecipeEntry> entries;

  RecipeFull(this.recipe, this.entries);
}