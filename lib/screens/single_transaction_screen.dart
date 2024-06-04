import 'package:biedronka_extractor/model/product.dart';
import 'package:biedronka_extractor/model/recipe_entry_full.dart';
import 'package:biedronka_extractor/model/recipe_full.dart';
import 'package:biedronka_extractor/my_database.dart';
import 'package:flutter/material.dart';

import 'components/add_product_dialog.dart';

class SingleTransactionScreen extends StatefulWidget {
  final RecipeFull recipe;

  const SingleTransactionScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _SingleTransactionScreenState createState() => _SingleTransactionScreenState();
}

class _SingleTransactionScreenState extends State<SingleTransactionScreen> {
  late RecipeFull _recipe;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productAmountController = TextEditingController();
  List<String> _productNames = [];

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _loadProductNames();
  }

  Future<void> _loadProductNames() async {
    List<Product> products = await MyDatabase.getAllProducts();
    setState(() {
      _productNames = products.map((product) => product.name).toList();
    });
  }

  void _refreshRecipe() async {
    var recipe = await MyDatabase.getRecipe(_recipe.recipe.id!);
    setState(() {
      _recipe = recipe;
    });
  }

  void _deleteTransaction() async {
    await MyDatabase.deleteRecipes({_recipe.recipe});
    Navigator.of(context).pop(true); // Return true to indicate the transaction was deleted
  }

  void _addProduct(Product product, double amount) async {
    await MyDatabase.insertRecipeEntry(_recipe, product, amount);
    _refreshRecipe();
  }

  void _deleteProduct(RecipeEntryFull entry) async {
    await MyDatabase.deleteRecipeEntry(entry.entry);
    _refreshRecipe();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transakcja ${_recipe.recipe.time}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTransaction,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _recipe.entries.length,
        itemBuilder: (context, index) {
          final entry = _recipe.entries[index];
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
