import 'package:floor/floor.dart';

@Entity(indices: [
  Index(value: ['name'], unique: true)
])
final class Product {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;

  Product(this.id, this.name);

  @override
  int get hashCode {
    return name.hashCode;
  }

  @override
  String toString() {
    return "$id $name";
  }

  @override
  bool operator ==(Object other) {
    return other is Product && other.name == name;
  }
}
