import 'package:biedronka_extractor/model/product.dart';
import 'package:floor/floor.dart';

@dao
abstract class ProductDao {
  @insert
  Future<Product> insertProduct(Product entryData);

  @Query('SELECT * FROM Product WHERE id=:id')
  Future<Product> getProduct(int id);

  @Query('SELECT * FROM Product ORDER BY id')
  Future<List<Product>> getAllProducts();
}
