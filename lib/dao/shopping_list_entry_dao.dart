import 'package:floor/floor.dart';

import '../model/shopping_list_entry.dart';

@dao
abstract class ShoppingListEntryDao {
  @insert
  Future<int> insertShoppingListEntry(ShoppingListEntry shoppingListEntry);

  @update
  Future<void> updateShoppingListEntry(ShoppingListEntry shoppingListEntry);

  @Query('SELECT * FROM ShoppingListEntry WHERE id = :id')
  Future<ShoppingListEntry?> getShoppingListEntry(int id);

  @Query('SELECT * FROM ShoppingListEntry WHERE shoppingListId = :shoppingListId ORDER BY id')
  Future<List<ShoppingListEntry>> getShoppingListEntriesByShoppingListId(int shoppingListId);

  @Query('SELECT * FROM ShoppingListEntry WHERE productId = :productId ORDER BY id')
  Future<List<ShoppingListEntry>> getShoppingListEntriesByProductId(int productId);

  @Query('SELECT * FROM ShoppingListEntry ORDER BY id')
  Future<List<ShoppingListEntry>> getAllShoppingListEntries();

  @delete
  Future<void> deleteShoppingListEntry(ShoppingListEntry id);

  @Query('DELETE FROM ShoppingListEntry WHERE shoppingListId = :shoppingListId')
  Future<void> deleteShoppingListEntriesByShoppingListId(int shoppingListId);

  @Query('DELETE FROM ShoppingListEntry WHERE productId = :productId')
  Future<void> deleteShoppingListEntriesByProductId(int productId);

  @Query('UPDATE ShoppingListEntry SET productId = :newProduct WHERE productId in (:toReplace)')
  Future<void> replaceProductsInShopping(int newProduct, List<int> toReplace);
}
