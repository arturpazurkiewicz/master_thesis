import 'package:biedronka_extractor/model/product.dart';
import 'package:biedronka_extractor/model/recipe_entry_full.dart';
import 'package:biedronka_extractor/model/recipe_full.dart';

import 'database_impl.dart';

class MyDatabase {
  static Future<FlutterDatabase>? _singleton;

  static Future<FlutterDatabase> _getInstance() {
    _singleton ??= $FloorFlutterDatabase.databaseBuilder('biedronka_extractor.db').build();
    return _singleton!;
  }

  static Future<void> saveFullRecipes(List<RecipeFull> recipes) async {
    var db = await _getInstance();
    for (var recipe in recipes) {
      var recipeId = await db.recipeDao.insertRecipe(recipe.recipe);
      for (var recipeEntryFull in recipe.entries) {
        var recipeEntry = recipeEntryFull.entry;
        recipeEntry.recipeId = recipeId;
        var product = await db.productDao.getProductOrInsert(recipeEntryFull.product);
        recipeEntry.productId = product.id!;
        recipeEntryFull.product = product;
      }
      await db.recipeEntryDao.insertAllRecipeData(recipe.entries.map((e) => e.entry).toList());
    }
  }

  static Future<List<RecipeFull>> getAllRecipes() async {
    var db = await _getInstance();
    List<RecipeFull> result = [];
    Map<int, Product> allProducts = {for (var product in await db.productDao.getAllProducts()) product.id!: product};
    for (var recipe in await db.recipeDao.getAllRecipes()) {
      var productEntries = await db.recipeEntryDao.getForRecipeId(recipe.id!);
      var recipeEntriesFull = productEntries.map((e) => RecipeEntryFull(e, allProducts[e.productId]!));
      result.add(RecipeFull(
        recipe, recipeEntriesFull.toList()
      ));
    }
    return result;
  }
}
