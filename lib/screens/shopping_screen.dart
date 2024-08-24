import 'package:biedronka_extractor/model/shopping_list.dart';
import 'package:biedronka_extractor/my_database.dart';
import 'package:biedronka_extractor/screens/single_shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Dodajemy import do obsługi formatowania daty

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  List<ShoppingList> _shoppingLists = [];
  bool _isSelectionMode = false;
  final Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    loadAllEntries();
  }

  void loadAllEntries() async {
    var data = await MyDatabase.getAllShoppingLists();
    setState(() {
      _shoppingLists = data;
    });
  }

  void _deleteSelectedShoppingLists() async {
    var selectedLists = _selectedIndexes.map((e) => _shoppingLists[e]).toList();
    await MyDatabase.deleteShoppingLists(selectedLists);

    loadAllEntries();
    setState(() {
      _selectedIndexes.clear();
      _isSelectionMode = false;
    });
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

  Future<void> _addNewShoppingList() async {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _dateController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Dodaj listę zakupową"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nazwa"),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Data"),
                readOnly: true,
                onTap: () async {
                  selectedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    locale: const Locale('pl'),
                  );
                  if (selectedDate != null) {
                    _dateController.text = DateFormat('dd.MM.yyyy').format(selectedDate!);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () async {
                String name = _nameController.text;
                String date = _dateController.text;

                // Add new shopping list
                await MyDatabase.insertShoppingList(name, DateFormat('dd.MM.yyyy').parse(date));
                Navigator.of(context).pop();
                loadAllEntries();
              },
              child: const Text("Dodaj"),
            ),
          ],
        );
      },
    );
  }

  void _showShoppingListDetails(ShoppingList shoppingList) async {
    var full = await MyDatabase.getShoppingListFull(shoppingList.id!);
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SingleShoppingListScreen(shoppingList: full),
      ),
    );
    loadAllEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listy zakupowe'),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedShoppingLists,
                )
              ]
            : [],
      ),
      body: ListView.builder(
        itemCount: _shoppingLists.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndexes.contains(index);
          return GestureDetector(
            onLongPress: () => _toggleSelection(index),
            child: ListTile(
              title: Text(_shoppingLists[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data: ${DateFormat('dd.MM.yyyy').format(_shoppingLists[index].date)}'),
                  FutureBuilder<int>(
                    future: MyDatabase.getShoppingListItemCount(_shoppingLists[index].id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Ilość produktów: ładowanie...');
                      } else if (snapshot.hasError) {
                        return const Text('Ilość produktów: błąd');
                      } else {
                        return Text('Ilość produktów: ${snapshot.data}');
                      }
                    },
                  ),
                ],
              ),
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
                  _showShoppingListDetails(_shoppingLists[index]);
                }
              },
              selected: isSelected,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewShoppingList,
        child: const Icon(Icons.add),
      ),
    );
  }
}
