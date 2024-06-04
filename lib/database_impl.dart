import 'dart:async';

import 'package:biedronka_extractor/dao/recipe_dao.dart';
import 'package:biedronka_extractor/dao/recipe_entry_dao.dart';
import 'package:biedronka_extractor/dao/shopping_list_entry_dao.dart';
import 'package:biedronka_extractor/model/recipe_entry.dart';
import 'package:biedronka_extractor/model/shopping_list.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'converter/date_time_converter.dart';
import 'dao/product_dao.dart';
import 'dao/shopping_list_dao.dart';
import 'model/product.dart';
import 'model/recipe.dart';
import 'model/shopping_list_entry.dart';

part 'database_impl.g.dart';

@Database(version: 1, entities: [Recipe, RecipeEntry, Product, ShoppingList, ShoppingListEntry])
abstract class FlutterDatabase extends FloorDatabase{
  RecipeDao get recipeDao;

  RecipeEntryDao get recipeEntryDao;

  ProductDao get productDao;

  ShoppingListDao get shoppingListDao;

  ShoppingListEntryDao get shoppingListEntryDao;
}
