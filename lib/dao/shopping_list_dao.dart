import 'package:floor/floor.dart';

import '../model/shopping_list.dart';

@dao
abstract class ShoppingListDao {
  @insert
  Future<int> insertShoppingList(ShoppingList shoppingList);

  @Query('SELECT * FROM ShoppingList WHERE id = :id')
  Future<ShoppingList?> getShoppingList(int id);

  @Query('SELECT * FROM ShoppingList ORDER BY date')
  Future<List<ShoppingList>> getAllShoppingLists();

  @Query('SELECT COUNT(*) FROM ShoppingListEntry WHERE shoppingListId = :shoppingListId')
  Future<int?> getShoppingListItemCount(int shoppingListId);

  @delete
  Future<void> deleteShoppingLists(List<ShoppingList> id);
}
