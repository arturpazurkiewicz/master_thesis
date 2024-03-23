import 'package:biedronka_extractor/model/recipe.dart';
import 'package:floor/floor.dart';

@dao
abstract class RecipeDao{
  @insert
  Future<int> insertRecipe(Recipe entryData);
  @insert
  Future<List<int>> insertAllRecipes(List<Recipe> data);

  @Query('SELECT * FROM Recipe ORDER BY time DESC')
  Future<List<Recipe>> getAllRecipes();
}