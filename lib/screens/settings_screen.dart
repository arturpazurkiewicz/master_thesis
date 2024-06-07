import 'package:biedronka_extractor/model/recipe_entry_full.dart';
import 'package:biedronka_extractor/my_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../algorithm/levenshtein.dart';
import '../model/product.dart';
import '../model/recipe_full.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _knnController = TextEditingController();
  final TextEditingController _cosineController = TextEditingController();
  final TextEditingController _aprioriSupportController = TextEditingController();
  final TextEditingController _aprioriTimeSupportController = TextEditingController();
  final TextEditingController _levenshteinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _knnController.text = (prefs.getInt('knn') ?? 7).toString();
      _cosineController.text = (prefs.getInt('cosine') ?? 7).toString();
      _aprioriSupportController.text = (prefs.getDouble('aprioriSupport') ?? 2.0).toString();
      _aprioriTimeSupportController.text = (prefs.getDouble('aprioriTimeSupport') ?? 2.0).toString();
      _levenshteinController.text = (prefs.getInt('levenshtein') ?? 2).toString();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('knn', int.tryParse(_knnController.text) ?? 7);
    await prefs.setInt('cosine', int.tryParse(_cosineController.text) ?? 7);
    await prefs.setDouble('aprioriSupport', double.tryParse(_aprioriSupportController.text) ?? 2.0);
    await prefs.setDouble('aprioriTimeSupport', double.tryParse(_aprioriTimeSupportController.text) ?? 2.0);
    await prefs.setInt('levenshtein', int.tryParse(_levenshteinController.text) ?? 2);
  }

  Future<void> _mergeSimilarProducts() async {
    final prefs = await SharedPreferences.getInstance();
    int levenshteinDistance = prefs.getInt('levenshtein') ?? 2;

    // Pobierz wszystkie produkty z bazy danych
    List<Product> products = await MyDatabase.getAllProducts();
    List<RecipeFull> recipes = await MyDatabase.getAllRecipes();
    List<RecipeEntryFull> recipeEntries = recipes.map((e) => e.entries).fold([], (previousValue, element) => previousValue + element);
    // Ustal najbardziej prawdopodobną nazwę produktu na podstawie ilości wystąpień
    Map<String, int> productCounts = {};
    for (var recipeEntry in recipeEntries) {
      productCounts[recipeEntry.product.name] = (productCounts[recipeEntry.product.name] ?? 0) + 1;
    }

    // Przekształć mapę na listę posortowaną malejąco po ilości wystąpień
    List<MapEntry<String, int>> sortedProductCounts = productCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Mapowanie nazw produktów na ich identyfikatory
    Map<String, List<int>> productIds = {};
    for (var product in products) {
      productIds.putIfAbsent(product.name, () => []).add(product.id!);
    }

    // Iteruj po produktach i scalaj te, które mają odległość Levenshteina mniejszą lub równą zadanemu progowi
    for (int i = 0; i < sortedProductCounts.length; i++) {
      for (int j = i + 1; j < sortedProductCounts.length; j++) {
        int distance = Levenshtein.distance(sortedProductCounts[i].key, sortedProductCounts[j].key);
        if (distance <= levenshteinDistance) {
          // Scal produkty
          String mainProductName = sortedProductCounts[i].key;
          String secondaryProductName = sortedProductCounts[j].key;

          await MyDatabase.mergeProducts(mainProductName, productIds[secondaryProductName]!);
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produkty zostały scalone')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ustawienia zapisane')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _knnController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'K dla KNN'),
            ),
            TextField(
              controller: _cosineController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'K dla Podobieństwo kosinusowe'),
            ),
            TextField(
              controller: _aprioriSupportController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minimalne wsparcie dla Apriori'),
            ),
            TextField(
              controller: _aprioriTimeSupportController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minimalne wsparcie dla Apriori z czasem'),
            ),
            TextField(
              controller: _levenshteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Odległość Levenshteina'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _mergeSimilarProducts,
              child: const Text('Uruchom'),
            ),
          ],
        ),
      ),
    );
  }
}
