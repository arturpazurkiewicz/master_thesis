import 'package:biedronka_extractor/model/recipe.dart';
import 'package:biedronka_extractor/model/recipe_entry.dart';
import 'package:biedronka_extractor/model/recipe_entry_full.dart';

class RecipeFull{
  final Recipe recipe;
  final List<RecipeEntryFull> entries;

  RecipeFull(this.recipe, this.entries);
}