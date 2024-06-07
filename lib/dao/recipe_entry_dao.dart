import 'package:floor/floor.dart';

import '../model/recipe_entry.dart';

@dao
abstract class RecipeEntryDao{
  @insert
  Future<void> insertRecipeData(RecipeEntry entryData);

  @insert
  Future<void> insertAllRecipeData(List<RecipeEntry> data);

  @Query('SELECT * FROM RecipeEntry ORDER BY time DESC')
  Future<List<RecipeEntry>> getAllEntries();

  @Query('SELECT * FROM RecipeEntry WHERE recipeId = :recipeId ORDER BY id')
  Future<List<RecipeEntry>> getForRecipeId(int recipeId);

  @delete
  Future<void> deleteRecipeEntry(RecipeEntry recipeEntry);

  @Query('UPDATE RecipeEntry SET productId = :newProduct WHERE productId in (:toReplace)')
  Future<void> replaceProducts(int newProduct, List<int> toReplace);
}