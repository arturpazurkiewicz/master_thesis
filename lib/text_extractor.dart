import 'dart:ffi';

import 'package:biedronka_extractor/model/product.dart';
import 'package:biedronka_extractor/model/recipe.dart';
import 'package:biedronka_extractor/model/recipe_entry_full.dart';
import 'package:biedronka_extractor/model/recipe_full.dart';
import 'package:intl/intl.dart';

import 'model/recipe_entry.dart';

class TextExtractor {
  final RegExp dateRegex = RegExp(r'\d{2}.\d{2}.\d{4} \d{2}:\d{2}');
  final DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  DateTime? extractDate(String text) {
    var match = dateRegex.firstMatch(text);
    if (match != null) {
      return dateFormat.parse(match.group(0)!);
    }
    return null;
  }

  final RegExp itemRegex = RegExp(r'^(?<name>[\S ]*?\S)\s+\w\s+(?<value>\d+\.\d+)\s*x', multiLine: true);

  RecipeFull extractRecipe(String text, DateTime time) {
    List<RecipeEntryFull> result = [];
    var matches = itemRegex.allMatches(text);
    for (var match in matches) {
      String? name = match.namedGroup("name");
      String? value = match.namedGroup("value");
      if (name != null && value != null) {
        var recipeEntry = RecipeEntry(null, -1, double.parse(value), -1);
        var product = Product(null, name);
        result.add(RecipeEntryFull(recipeEntry, product));
      }
    }

    return RecipeFull(Recipe(null, time), result);
  }
}
