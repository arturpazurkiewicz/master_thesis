import 'package:biedronka_extractor/algorithm_factory/apriori_factory.dart';
import 'package:biedronka_extractor/algorithm_factory/apriori_with_time_factory.dart';
import 'package:biedronka_extractor/algorithm_factory/cosine_similarity_factory.dart';
import 'package:biedronka_extractor/algorithm_factory/knn_factory.dart';
import 'package:biedronka_extractor/model/product.dart';
import 'package:biedronka_extractor/model/shopping_list_full.dart';
import 'package:biedronka_extractor/my_database.dart';
import 'package:flutter/material.dart';

import '../algorithm_factory/algorithm.dart';
import '../model/shopping_list_entry_full.dart';
import 'components/add_product_dialog.dart';

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

  final List<Algorithm> algorithms = [AprioriFactory(2.0), AprioriWithTimeFactory(2.0), CosineSimilarityFactory(7), KNNFactory(7)];
  final List<String> algorithmNames = ['Apriori', 'Apriori z czasem', 'Podobieństwo kosinusowe', 'KNN'];
  final Map<String, List<String>> algorithmResults = {};

  @override
  void initState() {
    super.initState();
    _shoppingList = widget.shoppingList;
    _loadProductNames();
    _preprocessAlgorithms();
  }

  Future<void> _loadProductNames() async {
    List<Product> products = await MyDatabase.getAllProducts();
    setState(() {
      _productNames = products.map((product) => product.name).toList();
      _productIdsToNames = {for (var product in products) product.id!: product.name};
    });
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

  void _showAddProductDialog() {
    _productNameController.clear();
    _productAmountController.clear();

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

  void _preprocessAlgorithms() {
    // Pobranie wszystkich transakcji z bazy danych
    MyDatabase.getAllRecipes().then((transactions) {
      for (var algorithm in algorithms) {
        algorithm.preprocess(transactions);
      }
    });
  }

  void _proposeProducts() {
    Set<int> currentProducts = _shoppingList.entries.map((e) => e.product.id!).toSet();
    DateTime shoppingDate = _shoppingList.shoppingList.date;

    for (int i = 0; i < algorithms.length; i++) {
      var algorithm = algorithms[i];
      Set<int> proposedProducts = algorithm.calculate(currentProducts, shoppingDate);
      List<String> productNames = proposedProducts.map((e) => _productIdsToNames[e]!).toList();
      productNames.sort();
      setState(() {
        algorithmResults[algorithmNames[i]] = productNames;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista zakupowa ${_shoppingList.shoppingList.date}"),
        actions: [
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
                  children: algorithmNames.map((name) {
                    final products = algorithmResults[name] ?? [];
                    return Container(
                      width: (MediaQuery.of(context).size.width - 32) / 2, // 2 kolumny z odstępem
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
