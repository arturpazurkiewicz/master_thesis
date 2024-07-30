import 'package:biedronka_extractor/algorithm_factory/apriori_factory.dart';
import 'package:biedronka_extractor/algorithm_factory/apriori_with_time_factory.dart';
import 'package:biedronka_extractor/algorithm_factory/cosine_similarity_factory.dart';
import 'package:biedronka_extractor/algorithm_factory/knn_factory.dart';
import 'package:biedronka_extractor/algorithm_factory/unprocessed_algorithm.dart';
import 'package:biedronka_extractor/model/product.dart';
import 'package:biedronka_extractor/model/shopping_list_full.dart';
import 'package:biedronka_extractor/my_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../algorithm_factory/preprocessed_algorithm.dart';
import '../model/recipe_full.dart';
import '../model/shopping_list_entry_full.dart';
import 'components/add_product_dialog.dart';

enum AlgorithmStatus { idle, preprocessing, processing }

class AlgorithmState {
  final String name;
  final UnprocessedAlgorithm unprocessedAlgorithm;
  PreprocessedAlgorithm? preprocessedAlgorithm;
  List<String> results = [];
  AlgorithmStatus status = AlgorithmStatus.idle;

  AlgorithmState(this.name, this.unprocessedAlgorithm);
}

class SingleShoppingListScreen extends StatefulWidget {
  final ShoppingListFull shoppingList;

  const SingleShoppingListScreen({Key? key, required this.shoppingList}) : super(key: key);

  @override
  _SingleShoppingListScreenState createState() => _SingleShoppingListScreenState();
}

class _SingleShoppingListScreenState extends State<SingleShoppingListScreen> {
  late ShoppingListFull _shoppingList;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productAmountController = TextEditingController();
  List<String> _productNames = [];
  Map<int, String> _productIdsToNames = {};
  List<AlgorithmState> algorithms = [];

  @override
  void initState() {
    super.initState();
    _shoppingList = widget.shoppingList;
    _loadProductNames();
    _loadAlgorithms();
  }

  Future<void> _loadProductNames() async {
    List<Product> products = await MyDatabase.getAllProducts();
    setState(() {
      _productNames = products.map((product) => product.name).toList();
      _productIdsToNames = {for (var product in products) product.id!: product.name};
    });
  }

  Future<void> _loadAlgorithms() async {
    final prefs = await SharedPreferences.getInstance();
    int knn = prefs.getInt('knn') ?? 7;
    int cosine = prefs.getInt('cosine') ?? 7;
    double aprioriSupport = prefs.getDouble('aprioriSupport') ?? 2.0;
    double aprioriTimeSupport = prefs.getDouble('aprioriTimeSupport') ?? 2.0;

    algorithms = [
      AlgorithmState('Apriori', AprioriFactory(aprioriSupport)),
      AlgorithmState('Apriori z czasem', AprioriWithTimeFactory(aprioriTimeSupport)),
      AlgorithmState('Podobieństwo kosinusowe', CosineSimilarityFactory(cosine)),
      AlgorithmState('KNN', KNNFactory(knn)),
    ];

    _preprocessAlgorithms();
  }

  void _refreshShoppingList() async {
    var shoppingList = await MyDatabase.getShoppingListFull(_shoppingList.shoppingList.id!);
    setState(() {
      _shoppingList = shoppingList;
      _proposeProducts(); // Automatycznie przeliczamy propozycje po odświeżeniu listy
    });
  }

  void _deleteShoppingList() async {
    await MyDatabase.deleteShoppingLists([_shoppingList.shoppingList]);
    Navigator.of(context).pop(true); // Return true to indicate the shopping list was deleted
  }

  void _addProduct(Product product, double amount) async {
    await MyDatabase.insertShoppingListEntry(_shoppingList.shoppingList, product, amount);
    _refreshShoppingList();
  }

  void _deleteProduct(ShoppingListEntryFull entry) async {
    await MyDatabase.deleteShoppingListEntry(entry.entry);
    _refreshShoppingList();
  }

  void _toggleMarked(ShoppingListEntryFull entry) async {
    entry.entry.toggleMarked();
    await MyDatabase.updateShoppingListEntry(entry.entry);
    _refreshShoppingList();
  }

  void _showAddProductDialog() {
    _productNameController.clear();
    _productAmountController.text = '1';

    showDialog(
      context: context,
      builder: (context) {
        return AddProductDialog(
          onProductAdded: (product, amount) {
            _addProduct(product, amount);
          },
          productNames: _productNames,
          productNameController: _productNameController,
          productAmountController: _productAmountController,
        );
      },
    );
  }

  Future<void> _preprocessAlgorithms() async {
    // Pobranie wszystkich transakcji z bazy danych
    List<RecipeFull> transactions = await MyDatabase.getAllRecipes();

    // Przetwarzanie równoległe
    await Future.wait(algorithms.map((algorithmState) async {
      setState(() {
        algorithmState.status = AlgorithmStatus.preprocessing;
      });
      print('Preprocessing ${algorithmState.name}...');
      final preprocessedAlgorithm = await compute(_runPreprocess, _PreprocessParams(algorithmState.unprocessedAlgorithm, transactions));
      setState(() {
        algorithmState.preprocessedAlgorithm = preprocessedAlgorithm;
        algorithmState.status = AlgorithmStatus.idle;
      });
      print('${algorithmState.name} preprocessing completed.');
    }));

    _proposeProducts();
  }

  static PreprocessedAlgorithm _runPreprocess(_PreprocessParams params) {
    return params.algorithm.preprocess(params.transactions);
  }

  Future<List<String>> _calculateProductsInIsolate(_AlgorithmParams params) async {
    final proposedProducts = await compute(_runAlgorithm, params);
    return proposedProducts.map((e) => params.productIdsToNames[e]!).toList();
  }

  static Set<int> _runAlgorithm(_AlgorithmParams params) {
    return params.algorithm.calculate(params.currentProducts, params.shoppingDate);
  }

  void _proposeProducts() {
    Set<int> currentProducts = _shoppingList.entries.map((e) => e.product.id!).toSet();
    DateTime shoppingDate = _shoppingList.shoppingList.date;

    // Kalkulacja równoległa
    algorithms.forEach((algorithmState) {
      final algorithmName = algorithmState.name;
      final preprocessedAlgorithm = algorithmState.preprocessedAlgorithm;

      if (preprocessedAlgorithm == null) {
        return;
      }

      setState(() {
        algorithmState.status = AlgorithmStatus.processing;
      });

      print('Calculating $algorithmName...');

      final params = _AlgorithmParams(
        preprocessedAlgorithm,
        currentProducts,
        shoppingDate,
        _productIdsToNames,
      );

      _calculateProductsInIsolate(params).then((productNames) {
        productNames.sort();
        setState(() {
          algorithmState.results = productNames;
          algorithmState.status = AlgorithmStatus.idle;
        });
        print('$algorithmName calculation completed.');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista zakupowa ${_shoppingList.shoppingList.date}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _preprocessAlgorithms,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteShoppingList,
          ),
        ],
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text("Propozycje"),
            onExpansionChanged: (bool expanded) {
              if (expanded) {
                _proposeProducts(); // Przelicz propozycje po otwarciu sekcji
              }
            },
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Wrap(
                  spacing: 4.0,
                  runSpacing: 8.0,
                  children: algorithms.map((algorithmState) {
                    final algorithmName = algorithmState.name;
                    final products = algorithmState.results;
                    return Container(
                      width: (MediaQuery.of(context).size.width - 32) / 2, // 2 kolumny z odstępem
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(algorithmName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (algorithmState.status == AlgorithmStatus.preprocessing)
                            const Text("Obliczanie...")
                          else if (algorithmState.status == AlgorithmStatus.processing)
                            const Text("Szacowanie...")
                          else
                            ...products.map((product) => Text(product)).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _shoppingList.entries.length,
              itemBuilder: (context, index) {
                final entry = _shoppingList.entries[index];
                return ListTile(
                  leading: Checkbox(
                    value: entry.entry.marked,
                    onChanged: (bool? value) {
                      _toggleMarked(entry);
                    },
                  ),
                  title: Text(entry.product.name),
                  subtitle: Text('Ilość: ${entry.entry.amount}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteProduct(entry),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PreprocessParams {
  final UnprocessedAlgorithm algorithm;
  final List<RecipeFull> transactions;

  _PreprocessParams(this.algorithm, this.transactions);
}

class _AlgorithmParams {
  final PreprocessedAlgorithm algorithm;
  final Set<int> currentProducts;
  final DateTime shoppingDate;
  final Map<int, String> productIdsToNames;

  _AlgorithmParams(this.algorithm, this.currentProducts, this.shoppingDate, this.productIdsToNames);
}
