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
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Recipe` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `time` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RecipeEntry` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `amount` REAL NOT NULL, `recipeId` INTEGER NOT NULL, FOREIGN KEY (`recipeId`) REFERENCES `Recipe` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');

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
    return _recipeEntryDaoInstance ??=
        _$RecipeEntryDao(database, changeListener);
  }
}

class _$RecipeDao extends RecipeDao {
  _$RecipeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recipeInsertionAdapter = InsertionAdapter(
            database,
            'Recipe',
            (Recipe item) => <String, Object?>{
                  'id': item.id,
                  'time': _dateTimeConverter.encode(item.time)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Recipe> _recipeInsertionAdapter;

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return _queryAdapter.queryList('SELECT * FROM Recipe ORDER BY time DESC',
        mapper: (Map<String, Object?> row) => Recipe(
            row['id'] as int?, _dateTimeConverter.decode(row['time'] as int)));
  }

  @override
  Future<int> insertRecipe(Recipe entryData) {
    return _recipeInsertionAdapter.insertAndReturnId(
        entryData, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAllRecipes(List<Recipe> data) {
    return _recipeInsertionAdapter.insertListAndReturnIds(
        data, OnConflictStrategy.abort);
  }
}

class _$RecipeEntryDao extends RecipeEntryDao {
  _$RecipeEntryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recipeEntryInsertionAdapter = InsertionAdapter(
            database,
            'RecipeEntry',
            (RecipeEntry item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'amount': item.amount,
                  'recipeId': item.recipeId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RecipeEntry> _recipeEntryInsertionAdapter;

  @override
  Future<List<RecipeEntry>> getAllEntries() async {
    return _queryAdapter.queryList(
        'SELECT * FROM RecipeEntry ORDER BY time DESC',
        mapper: (Map<String, Object?> row) => RecipeEntry(
            row['id'] as int?,
            row['name'] as String,
            row['amount'] as double,
            row['recipeId'] as int));
  }

  @override
  Future<List<RecipeEntry>> getForRecipeId(int recipeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RecipeEntry WHERE recipeId = ?1 ORDER BY id',
        mapper: (Map<String, Object?> row) => RecipeEntry(
            row['id'] as int?,
            row['name'] as String,
            row['amount'] as double,
            row['recipeId'] as int),
        arguments: [recipeId]);
  }

  @override
  Future<void> insertRecipeData(RecipeEntry entryData) async {
    await _recipeEntryInsertionAdapter.insert(
        entryData, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertAllRecipeData(List<RecipeEntry> data) async {
    await _recipeEntryInsertionAdapter.insertList(
        data, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
