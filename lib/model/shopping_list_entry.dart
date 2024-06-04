import 'package:biedronka_extractor/model/product.dart';
import 'package:biedronka_extractor/model/shopping_list.dart';
import 'package:floor/floor.dart';

@Entity(foreignKeys: [
  ForeignKey(childColumns: ['shoppingListId'], parentColumns: ['id'], entity: ShoppingList, onDelete: ForeignKeyAction.cascade),
  ForeignKey(childColumns: ['productId'], parentColumns: ['id'], entity: Product, onDelete: ForeignKeyAction.noAction),
])
class ShoppingListEntry {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  int productId;
  int shoppingListId;
  double amount;

  ShoppingListEntry(this.id, this.productId, this.shoppingListId, this.amount);
}
