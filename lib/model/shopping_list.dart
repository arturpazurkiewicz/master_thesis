import 'package:biedronka_extractor/converter/date_time_converter.dart';
import 'package:floor/floor.dart';

@Entity()
@TypeConverters([DateTimeConverter])
class ShoppingList {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final DateTime date;
  final String name;

  ShoppingList(this.id, this.date, this.name);
}
