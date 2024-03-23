import 'package:biedronka_extractor/converter/date_time_converter.dart';
import 'package:floor/floor.dart';

@Entity()
@TypeConverters([DateTimeConverter])
class Recipe{
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final DateTime time;
  Recipe(this.id, this.time);
}