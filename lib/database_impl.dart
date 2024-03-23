import 'dart:async';

import 'package:biedronka_extractor/dao/recipe_dao.dart';
import 'package:biedronka_extractor/dao/recipe_entry_dao.dart';
import 'package:biedronka_extractor/model/recipe_entry.dart';
import 'package:floor/floor.dart';

import 'converter/date_time_converter.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'model/recipe.dart';

part 'database_impl.g.dart';

@Database(version: 1, entities: [Recipe, RecipeEntry])
abstract class FlutterDatabase extends FloorDatabase{
  RecipeDao get recipeDao;
  RecipeEntryDao get recipeEntryDao;
}
