import 'package:biedronka_extractor/model/product.dart';
import 'package:floor/floor.dart';

@dao
abstract class ProductDao {
  @insert
  Future<int> insertProduct(Product entryData);

  @Query('SELECT * FROM Product WHERE id=:id')
  Future<Product?> getProduct(int id);

  @Query('SELECT * FROM Product WHERE name=:name')
  Future<Product?> getProductByName(String name);

  @Query('SELECT * FROM Product ORDER BY id')
  Future<List<Product>> getAllProducts();

  @Query('SELECT * FROM Product WHERE id in (:ids) ORDER BY name')
  Future<List<Product>> getProducts(List<int> ids);

  Future<Product> getProductOrInsert(String name) async {
    var product = await getProductByName(name);
    if (product == null) {
      product = Product(null, name);
      product.id = await insertProduct(product);
    }
    return product;
  }

  @delete
  Future<void> deleteProducts(List<Product> products);
}
