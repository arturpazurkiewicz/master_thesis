import 'package:biedronka_extractor/model/product.dart';
import 'package:biedronka_extractor/model/recipe.dart';
import 'package:biedronka_extractor/model/recipe_entry.dart';
import 'package:biedronka_extractor/model/recipe_entry_full.dart';
import 'package:biedronka_extractor/model/recipe_full.dart';
import 'package:biedronka_extractor/model/shopping_list_entry.dart';
import 'package:biedronka_extractor/model/shopping_list_entry_full.dart';
import 'package:biedronka_extractor/model/shopping_list_full.dart';
import 'package:floor/floor.dart';

import 'database_impl.dart';
import 'model/shopping_list.dart';

class MyDatabase {
  static Future<FlutterDatabase>? _singleton;

  static Future<FlutterDatabase> _getInstance() {
    _singleton ??= $FloorFlutterDatabase.databaseBuilder('biedronka_extractor.db').build();
    return _singleton!;
  }

  @transaction
  static Future<void> saveFullRecipes(List<RecipeFull> recipes) async {
    var db = await _getInstance();
    for (var recipe in recipes) {
      var recipeId = await db.recipeDao.insertRecipe(recipe.recipe);
      for (var recipeEntryFull in recipe.entries) {
        var recipeEntry = recipeEntryFull.entry;
        recipeEntry.recipeId = recipeId;
        var product = await db.productDao.getProductOrInsert(recipeEntryFull.product.name);
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
      result.add(RecipeFull(recipe, recipeEntriesFull.toList()));
    }
    return result;
  }

  static Future<void> deleteRecipes(Iterable<Recipe> recipes) async {
    var db = await _getInstance();
    await db.recipeDao.deleteRecipes(recipes.toList());
  }

  static Future<Product> getOrInsertProductByName(String name) async {
    var db = await _getInstance();
    return db.productDao.getProductOrInsert(name);
  }

  static Future<RecipeFull> getRecipe(int id) async {
    var db = await _getInstance();
    var recipe = await db.recipeDao.getRecipe(id);
    var productEntries = await db.recipeEntryDao.getForRecipeId(recipe!.id!);
    var productNames = await db.productDao.getProducts(productEntries.map((e) => e.productId).toList());
    Map<int, Product> allProducts = {for (var product in productNames) product.id!: product};
    return RecipeFull(recipe, productEntries.map((e) => RecipeEntryFull(e, allProducts[e.productId]!)).toList());
  }

  static Future<void> deleteRecipeEntry(RecipeEntry entry) async {
    var db = await _getInstance();
    await db.recipeEntryDao.deleteRecipeEntry(entry);
  }

  static Future<void> insertRecipeEntry(RecipeFull recipe, Product product, double amount) async {
    var db = await _getInstance();
    await db.recipeEntryDao.insertAllRecipeData([RecipeEntry(null, product.id!, amount, recipe.recipe.id!)]);
  }

  static Future<List<Product>> getAllProducts() async {
    var db = await _getInstance();
    return db.productDao.getAllProducts();
  }

  static Future<List<ShoppingList>> getAllShoppingLists() async {
    var db = await _getInstance();
    return db.shoppingListDao.getAllShoppingLists();
  }

  static Future<int> insertShoppingList(String name, DateTime date) async {
    var db = await _getInstance();
    return await db.shoppingListDao.insertShoppingList(ShoppingList(null, date, name));
  }

  static Future<void> deleteShoppingLists(List<ShoppingList> selectedLists) async {
    var db = await _getInstance();
    await db.shoppingListDao.deleteShoppingLists(selectedLists);
  }

  static Future<ShoppingListFull> getShoppingListFull(int id) async {
    var db = await _getInstance();
    var shoppingList = await db.shoppingListDao.getShoppingList(id);
    var shoppingListEntries = await db.shoppingListEntryDao.getShoppingListEntriesByShoppingListId(id);
    var products = await db.productDao.getProducts(shoppingListEntries.map((e) => e.productId).toList());
    var productMap = {for (var product in products) product.id!: product};
    return ShoppingListFull(shoppingList!, shoppingListEntries.map((e) => ShoppingListEntryFull(e, productMap[e.productId]!)).toList());
  }

  static Future<void> insertShoppingListEntry(ShoppingList shoppingList, Product product, double amount) async {
    var db = await _getInstance();
    await db.shoppingListEntryDao.insertShoppingListEntry(ShoppingListEntry(null, product.id!, shoppingList.id!, amount, false));
  }

  static Future<void> updateShoppingListEntry(ShoppingListEntry shoppingListEntry) async {
    var db = await _getInstance();
    await db.shoppingListEntryDao.updateShoppingListEntry(shoppingListEntry);
  }

  static Future<void> deleteShoppingListEntry(ShoppingListEntry entry) async {
    var db = await _getInstance();
    await db.shoppingListEntryDao.deleteShoppingListEntry(entry);
  }

  static Future<int> getShoppingListItemCount(int shoppingListId) async {
    var db = await _getInstance();
    return (await db.shoppingListDao.getShoppingListItemCount(shoppingListId))!;
  }

  @transaction
  static Future<void> mergeProducts(String mainProductName, List<int> secondaryProductIds) async {
    var db = await _getInstance();

    // Pobierz ID głównego produktu
    final Product? mainProduct = await db.productDao.getProductByName(mainProductName);

    if (mainProduct == null) {
      return;
    }

    var toReplace = await db.productDao.getProducts(secondaryProductIds);

    // Zaktualizuj wszystkie RecipeEntry, które mają secondaryProductIds
    await db.recipeEntryDao.replaceProducts(mainProduct.id!, toReplace.map((e) => e.id!).toList());
    await db.shoppingListEntryDao.replaceProductsInShopping(mainProduct.id!, toReplace.map((e) => e.id!).toList());
    // Usuń scalone produkty
    await db.productDao.deleteProducts(toReplace);
  }
}
