import 'package:biedronka_extractor/model/recipe.dart';
import 'package:biedronka_extractor/model/recipe_full.dart';

import 'database_impl.dart';

class MyDatabase {
  static Future<FlutterDatabase>? _singleton;

  static Future<FlutterDatabase> _getInstance() {
    _singleton ??= $FloorFlutterDatabase.databaseBuilder('biedronka_extractor.db').build();
    return _singleton!;
  }

  static Future<void> saveFullRecipes(List<RecipeFull> recipes) async{
    var db = await _getInstance();
    for (var recipe in recipes){
      var id = await db.recipeDao.insertRecipe(recipe.recipe);
      // for (var element in recipe.entries) { element.recipeId = id;} val TODO fix
      await db.recipeEntryDao.insertAllRecipeData(recipe.entries);
    }
  }

  static Future<List<RecipeFull>> getAllRecipes() async {
    var db = await _getInstance();
    List<RecipeFull> result = [];
    for (var recipe in  await db.recipeDao.getAllRecipes()){
      result.add(RecipeFull(recipe, await db.recipeEntryDao.getForRecipeId(recipe.id!)));
    }
    return result;
  }
}