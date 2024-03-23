import 'package:floor/floor.dart';
import 'package:biedronka_extractor/model/recipe.dart';
import '../converter/date_time_converter.dart';
import 'product.dart';

@Entity(foreignKeys: [
  ForeignKey(childColumns: ['recipeId'], parentColumns: ['id'], entity: Recipe, onDelete: ForeignKeyAction.cascade),
  ForeignKey(childColumns: ['productId'], parentColumns: ['id'], entity: Product, onDelete: ForeignKeyAction.noAction),
])
@TypeConverters([DateTimeConverter])
class RecipeEntry {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int productId;
  final double amount;
  final int recipeId;

  RecipeEntry(this.id, this.productId, this.amount, this.recipeId);

  @override
  String toString() {
    return "$productId   $amount   $recipeId";
  }
}