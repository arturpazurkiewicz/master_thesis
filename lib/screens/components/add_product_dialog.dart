import 'package:biedronka_extractor/model/product.dart';
import 'package:biedronka_extractor/my_database.dart';
import 'package:flutter/material.dart';

class AddProductDialog extends StatefulWidget {
  final Function(Product, double) onProductAdded;
  final List<String> productNames;
  final TextEditingController productNameController;
  final TextEditingController productAmountController;

  const AddProductDialog({
    Key? key,
    required this.onProductAdded,
    required this.productNames,
    required this.productNameController,
    required this.productAmountController,
  }) : super(key: key);

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Dodaj produkt"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return widget.productNames.where((String name) {
                return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              widget.productNameController.text = selection;
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: "Nazwa produktu"),
                onChanged: (value) {
                  widget.productNameController.text = value;
                },
                onSubmitted: (value) {
                  widget.productNameController.text = value;
                },
              );
            },
          ),
          TextField(
            controller: widget.productAmountController,
            decoration: const InputDecoration(labelText: "Ilość"),
            keyboardType: TextInputType.number,
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
            String name = widget.productNameController.text;
            double amount = double.tryParse(widget.productAmountController.text) ?? 0;

            Product product = await MyDatabase.getOrInsertProductByName(name);
            widget.onProductAdded(product, amount);
            Navigator.of(context).pop();
          },
          child: const Text("Dodaj"),
        ),
      ],
    );
  }
}
