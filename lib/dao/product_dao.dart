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

  Future<Product> getProductOrInsert(Product newProduct) async {
    var product = await getProductByName(newProduct.name);
    if (product == null) {
      var id = await insertProduct(newProduct);
      newProduct.id = id;
      product = newProduct;
    }
      return product;
  }
}
