// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_impl.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorFlutterDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder databaseBuilder(String name) =>
      _$FlutterDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$FlutterDatabaseBuilder(null);
}

class _$FlutterDatabaseBuilder {
  _$FlutterDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$FlutterDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$FlutterDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<FlutterDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$FlutterDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FlutterDatabase extends FlutterDatabase {
  _$FlutterDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RecipeDao? _recipeDaoInstance;

  RecipeEntryDao? _recipeEntryDaoInstance;

  ProductDao? _productDaoInstance;

  ShoppingListDao? _shoppingListDaoInstance;

  ShoppingListEntryDao? _shoppingListEntryDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute('CREATE TABLE IF NOT EXISTS `Recipe` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `time` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RecipeEntry` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `productId` INTEGER NOT NULL, `amount` REAL NOT NULL, `recipeId` INTEGER NOT NULL, FOREIGN KEY (`recipeId`) REFERENCES `Recipe` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`productId`) REFERENCES `Product` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute('CREATE TABLE IF NOT EXISTS `Product` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL)');
        await database
            .execute('CREATE TABLE IF NOT EXISTS `ShoppingList` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `date` INTEGER NOT NULL, `name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ShoppingListEntry` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `productId` INTEGER NOT NULL, `shoppingListId` INTEGER NOT NULL, `amount` REAL NOT NULL, `marked` INTEGER NOT NULL, FOREIGN KEY (`shoppingListId`) REFERENCES `ShoppingList` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`productId`) REFERENCES `Product` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute('CREATE UNIQUE INDEX `index_Product_name` ON `Product` (`name`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RecipeDao get recipeDao {
    return _recipeDaoInstance ??= _$RecipeDao(database, changeListener);
  }

  @override
  RecipeEntryDao get recipeEntryDao {
    return _recipeEntryDaoInstance ??= _$RecipeEntryDao(database, changeListener);
  }

  @override
  ProductDao get productDao {
    return _productDaoInstance ??= _$ProductDao(database, changeListener);
  }

  @override
  ShoppingListDao get shoppingListDao {
    return _shoppingListDaoInstance ??= _$ShoppingListDao(database, changeListener);
  }

  @override
  ShoppingListEntryDao get shoppingListEntryDao {
    return _shoppingListEntryDaoInstance ??= _$ShoppingListEntryDao(database, changeListener);
  }
}

class _$RecipeDao extends RecipeDao {
  _$RecipeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recipeInsertionAdapter =
            InsertionAdapter(database, 'Recipe', (Recipe item) => <String, Object?>{'id': item.id, 'time': _dateTimeConverter.encode(item.time)}),
        _recipeDeletionAdapter =
            DeletionAdapter(database, 'Recipe', ['id'], (Recipe item) => <String, Object?>{'id': item.id, 'time': _dateTimeConverter.encode(item.time)});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Recipe> _recipeInsertionAdapter;

  final DeletionAdapter<Recipe> _recipeDeletionAdapter;

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return _queryAdapter.queryList('SELECT * FROM Recipe ORDER BY time DESC',
        mapper: (Map<String, Object?> row) => Recipe(row['id'] as int?, _dateTimeConverter.decode(row['time'] as int)));
  }

  @override
  Future<Recipe?> getRecipe(int id) async {
    return _queryAdapter.query('SELECT * FROM Recipe WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Recipe(row['id'] as int?, _dateTimeConverter.decode(row['time'] as int)), arguments: [id]);
  }

  @override
  Future<int> insertRecipe(Recipe entryData) {
    return _recipeInsertionAdapter.insertAndReturnId(entryData, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAllRecipes(List<Recipe> data) {
    return _recipeInsertionAdapter.insertListAndReturnIds(data, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecipes(List<Recipe> recipe) async {
    await _recipeDeletionAdapter.deleteList(recipe);
  }
}

class _$RecipeEntryDao extends RecipeEntryDao {
  _$RecipeEntryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recipeEntryInsertionAdapter = InsertionAdapter(database, 'RecipeEntry',
            (RecipeEntry item) => <String, Object?>{'id': item.id, 'productId': item.productId, 'amount': item.amount, 'recipeId': item.recipeId}),
        _recipeEntryDeletionAdapter = DeletionAdapter(database, 'RecipeEntry', ['id'],
            (RecipeEntry item) => <String, Object?>{'id': item.id, 'productId': item.productId, 'amount': item.amount, 'recipeId': item.recipeId});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RecipeEntry> _recipeEntryInsertionAdapter;

  final DeletionAdapter<RecipeEntry> _recipeEntryDeletionAdapter;

  @override
  Future<List<RecipeEntry>> getAllEntries() async {
    return _queryAdapter.queryList('SELECT * FROM RecipeEntry ORDER BY time DESC',
        mapper: (Map<String, Object?> row) => RecipeEntry(row['id'] as int?, row['productId'] as int, row['amount'] as double, row['recipeId'] as int));
  }

  @override
  Future<List<RecipeEntry>> getForRecipeId(int recipeId) async {
    return _queryAdapter.queryList('SELECT * FROM RecipeEntry WHERE recipeId = ?1 ORDER BY id',
        mapper: (Map<String, Object?> row) => RecipeEntry(row['id'] as int?, row['productId'] as int, row['amount'] as double, row['recipeId'] as int),
        arguments: [recipeId]);
  }

  @override
  Future<void> replaceProducts(
    int newProduct,
    List<int> toReplace,
  ) async {
    const offset = 2;
    final _sqliteVariablesForToReplace = Iterable<String>.generate(toReplace.length, (i) => '?${i + offset}').join(',');
    await _queryAdapter.queryNoReturn('UPDATE RecipeEntry SET productId = ?1 WHERE productId in (' + _sqliteVariablesForToReplace + ')',
        arguments: [newProduct, ...toReplace]);
  }

  @override
  Future<void> insertRecipeData(RecipeEntry entryData) async {
    await _recipeEntryInsertionAdapter.insert(entryData, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertAllRecipeData(List<RecipeEntry> data) async {
    await _recipeEntryInsertionAdapter.insertList(data, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecipeEntry(RecipeEntry recipeEntry) async {
    await _recipeEntryDeletionAdapter.delete(recipeEntry);
  }
}

class _$ProductDao extends ProductDao {
  _$ProductDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _productInsertionAdapter = InsertionAdapter(database, 'Product', (Product item) => <String, Object?>{'id': item.id, 'name': item.name}),
        _productDeletionAdapter = DeletionAdapter(database, 'Product', ['id'], (Product item) => <String, Object?>{'id': item.id, 'name': item.name});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Product> _productInsertionAdapter;

  final DeletionAdapter<Product> _productDeletionAdapter;

  @override
  Future<Product?> getProduct(int id) async {
    return _queryAdapter
        .query('SELECT * FROM Product WHERE id=?1', mapper: (Map<String, Object?> row) => Product(row['id'] as int?, row['name'] as String), arguments: [id]);
  }

  @override
  Future<Product?> getProductByName(String name) async {
    return _queryAdapter.query('SELECT * FROM Product WHERE name=?1',
        mapper: (Map<String, Object?> row) => Product(row['id'] as int?, row['name'] as String), arguments: [name]);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    return _queryAdapter.queryList('SELECT * FROM Product ORDER BY id',
        mapper: (Map<String, Object?> row) => Product(row['id'] as int?, row['name'] as String));
  }

  @override
  Future<List<Product>> getProducts(List<int> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds = Iterable<String>.generate(ids.length, (i) => '?${i + offset}').join(',');
    return _queryAdapter.queryList('SELECT * FROM Product WHERE id in (' + _sqliteVariablesForIds + ') ORDER BY name',
        mapper: (Map<String, Object?> row) => Product(row['id'] as int?, row['name'] as String), arguments: [...ids]);
  }

  @override
  Future<int> insertProduct(Product entryData) {
    return _productInsertionAdapter.insertAndReturnId(entryData, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProducts(List<Product> products) async {
    await _productDeletionAdapter.deleteList(products);
  }
}

class _$ShoppingListDao extends ShoppingListDao {
  _$ShoppingListDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _shoppingListInsertionAdapter = InsertionAdapter(
            database, 'ShoppingList', (ShoppingList item) => <String, Object?>{'id': item.id, 'date': _dateTimeConverter.encode(item.date), 'name': item.name}),
        _shoppingListDeletionAdapter = DeletionAdapter(database, 'ShoppingList', ['id'],
            (ShoppingList item) => <String, Object?>{'id': item.id, 'date': _dateTimeConverter.encode(item.date), 'name': item.name});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ShoppingList> _shoppingListInsertionAdapter;

  final DeletionAdapter<ShoppingList> _shoppingListDeletionAdapter;

  @override
  Future<ShoppingList?> getShoppingList(int id) async {
    return _queryAdapter.query('SELECT * FROM ShoppingList WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ShoppingList(row['id'] as int?, _dateTimeConverter.decode(row['date'] as int), row['name'] as String),
        arguments: [id]);
  }

  @override
  Future<List<ShoppingList>> getAllShoppingLists() async {
    return _queryAdapter.queryList('SELECT * FROM ShoppingList ORDER BY date',
        mapper: (Map<String, Object?> row) => ShoppingList(row['id'] as int?, _dateTimeConverter.decode(row['date'] as int), row['name'] as String));
  }

  @override
  Future<int?> getShoppingListItemCount(int shoppingListId) async {
    return _queryAdapter.query('SELECT COUNT(*) FROM ShoppingListEntry WHERE shoppingListId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int, arguments: [shoppingListId]);
  }

  @override
  Future<int> insertShoppingList(ShoppingList shoppingList) {
    return _shoppingListInsertionAdapter.insertAndReturnId(shoppingList, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteShoppingLists(List<ShoppingList> id) async {
    await _shoppingListDeletionAdapter.deleteList(id);
  }
}

class _$ShoppingListEntryDao extends ShoppingListEntryDao {
  _$ShoppingListEntryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _shoppingListEntryInsertionAdapter = InsertionAdapter(
            database,
            'ShoppingListEntry',
            (ShoppingListEntry item) => <String, Object?>{
                  'id': item.id,
                  'productId': item.productId,
                  'shoppingListId': item.shoppingListId,
                  'amount': item.amount,
                  'marked': item.marked ? 1 : 0
                }),
        _shoppingListEntryUpdateAdapter = UpdateAdapter(
            database,
            'ShoppingListEntry',
            ['id'],
            (ShoppingListEntry item) => <String, Object?>{
                  'id': item.id,
                  'productId': item.productId,
                  'shoppingListId': item.shoppingListId,
                  'amount': item.amount,
                  'marked': item.marked ? 1 : 0
                }),
        _shoppingListEntryDeletionAdapter = DeletionAdapter(
            database,
            'ShoppingListEntry',
            ['id'],
            (ShoppingListEntry item) => <String, Object?>{
                  'id': item.id,
                  'productId': item.productId,
                  'shoppingListId': item.shoppingListId,
                  'amount': item.amount,
                  'marked': item.marked ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ShoppingListEntry> _shoppingListEntryInsertionAdapter;

  final UpdateAdapter<ShoppingListEntry> _shoppingListEntryUpdateAdapter;

  final DeletionAdapter<ShoppingListEntry> _shoppingListEntryDeletionAdapter;

  @override
  Future<ShoppingListEntry?> getShoppingListEntry(int id) async {
    return _queryAdapter.query('SELECT * FROM ShoppingListEntry WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            ShoppingListEntry(row['id'] as int?, row['productId'] as int, row['shoppingListId'] as int, row['amount'] as double, (row['marked'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<List<ShoppingListEntry>> getShoppingListEntriesByShoppingListId(int shoppingListId) async {
    return _queryAdapter.queryList('SELECT * FROM ShoppingListEntry WHERE shoppingListId = ?1 ORDER BY id',
        mapper: (Map<String, Object?> row) =>
            ShoppingListEntry(row['id'] as int?, row['productId'] as int, row['shoppingListId'] as int, row['amount'] as double, (row['marked'] as int) != 0),
        arguments: [shoppingListId]);
  }

  @override
  Future<List<ShoppingListEntry>> getShoppingListEntriesByProductId(int productId) async {
    return _queryAdapter.queryList('SELECT * FROM ShoppingListEntry WHERE productId = ?1 ORDER BY id',
        mapper: (Map<String, Object?> row) =>
            ShoppingListEntry(row['id'] as int?, row['productId'] as int, row['shoppingListId'] as int, row['amount'] as double, (row['marked'] as int) != 0),
        arguments: [productId]);
  }

  @override
  Future<List<ShoppingListEntry>> getAllShoppingListEntries() async {
    return _queryAdapter.queryList('SELECT * FROM ShoppingListEntry ORDER BY id',
        mapper: (Map<String, Object?> row) =>
            ShoppingListEntry(row['id'] as int?, row['productId'] as int, row['shoppingListId'] as int, row['amount'] as double, (row['marked'] as int) != 0));
  }

  @override
  Future<void> deleteShoppingListEntriesByShoppingListId(int shoppingListId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM ShoppingListEntry WHERE shoppingListId = ?1', arguments: [shoppingListId]);
  }

  @override
  Future<void> deleteShoppingListEntriesByProductId(int productId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM ShoppingListEntry WHERE productId = ?1', arguments: [productId]);
  }

  @override
  Future<void> replaceProductsInShopping(
    int newProduct,
    List<int> toReplace,
  ) async {
    const offset = 2;
    final _sqliteVariablesForToReplace = Iterable<String>.generate(toReplace.length, (i) => '?${i + offset}').join(',');
    await _queryAdapter.queryNoReturn('UPDATE ShoppingListEntry SET productId = ?1 WHERE productId in (' + _sqliteVariablesForToReplace + ')',
        arguments: [newProduct, ...toReplace]);
  }

  @override
  Future<int> insertShoppingListEntry(ShoppingListEntry shoppingListEntry) {
    return _shoppingListEntryInsertionAdapter.insertAndReturnId(shoppingListEntry, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateShoppingListEntry(ShoppingListEntry shoppingListEntry) async {
    await _shoppingListEntryUpdateAdapter.update(shoppingListEntry, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteShoppingListEntry(ShoppingListEntry id) async {
    await _shoppingListEntryDeletionAdapter.delete(id);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
