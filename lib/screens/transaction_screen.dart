import 'package:biedronka_extractor/OCR.dart';
import 'package:biedronka_extractor/model/recipe_full.dart';
import 'package:biedronka_extractor/my_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'single_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final OCR _ocr = OCR();
  List<RecipeFull> _recipes = [];
  bool _isSelectionMode = false;
  final Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    loadAllEntries();
  }

  void loadAllEntries() async {
    var data = await MyDatabase.getAllRecipes();
    setState(() {
      _recipes = data;
    });
  }

  void _deleteSelectedRecipes() async {
    var r = _recipes;
    var selectedRecipes = _selectedIndexes.map((e) => _recipes[e]);
    await MyDatabase.deleteRecipes(selectedRecipes.map((e) => e.recipe));

    setState(() {
      _selectedIndexes.clear();
      _isSelectionMode = false;
    });
    loadAllEntries();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
        if (_selectedIndexes.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIndexes.add(index);
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _addNewRecipe() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballRotateChase,
                  ),
                ),
                SizedBox(width: 16),
                Text("Dodawanie..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['pdf'],
      );

      List<RecipeFull> recipes = [];
      if (result != null) {
        for (var file in result.files) {
          var recipe = await _ocr.runOCR(file);
          if (recipe != null) recipes.add(recipe);
        }
        await MyDatabase.saveFullRecipes(recipes);
      }

      loadAllEntries();
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wystąpił błąd: $e'),
        ),
      );
    }
  }

  void _showRecipeDetails(RecipeFull recipe) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SingleTransactionScreen(recipe: recipe),
      ),
    );

    loadAllEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transakcje'),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedRecipes,
                )
              ]
            : [],
      ),
      body: ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndexes.contains(index);
          return GestureDetector(
            onLongPress: () => _toggleSelection(index),
            child: ListTile(
              title: Text(_recipes[index].recipe.time.toString()),
              subtitle: Text('Ilość pozycji: ${_recipes[index].entries.length}'),
              trailing: _isSelectionMode
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (bool? selected) {
                        _toggleSelection(index);
                      },
                    )
                  : null,
              onTap: () {
                if (_isSelectionMode) {
                  _toggleSelection(index);
                } else {
                  _showRecipeDetails(_recipes[index]);
                }
              },
              selected: isSelected,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }
}
