import 'package:biedronka_extractor/model/shopping_list.dart';
import 'package:biedronka_extractor/model/shopping_list_entry_full.dart';

class ShoppingListFull {
  final ShoppingList shoppingList;
  final List<ShoppingListEntryFull> entries;

  ShoppingListFull(this.shoppingList, this.entries);

  @override
  String toString() {
    return entries.toString();
  }
}
