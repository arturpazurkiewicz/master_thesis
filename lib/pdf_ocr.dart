import 'dart:io';

import 'package:biedronka_extractor/algorithm_factory/apriori_factory.dart';
import 'package:biedronka_extractor/model/recipe_full.dart';
import 'package:biedronka_extractor/my_database.dart';
import 'package:biedronka_extractor/text_extractor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF OCR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PdfOcr(),
    );
  }
}

class PdfOcr extends StatefulWidget {
  const PdfOcr({super.key});

  @override
  State<PdfOcr> createState() => _PdfOcrState();
}

class _PdfOcrState extends State<PdfOcr> {
  List<RecipeFull> _recipes = List.empty();

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

  void _openFileExplorer(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['pdf'],
      );
      List<RecipeFull> recipes = [];
      if (result != null) {
        for (var file in result.files) {
          var recipe = await runOCR(file);
          print("Found ${recipe?.entries.length}");
          if (recipe != null) recipes.add(recipe);
        }
      }
      setState(() {
        _recipes = recipes;
      });
      MyDatabase.saveFullRecipes(recipes);
    } catch (e) {
      print('Wystąpił błąd: $e');
    }
  }

  Future<RecipeFull?> runOCR(PlatformFile file) async {
    var document = await PdfDocument.openFile(file.path!);
    final tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/temporary_image.png';
    var text = '';

    for (var i = 1; i <= document.pagesCount; i++) {
      if (i != 1) {
        document = await PdfDocument.openFile(file.path!);
      }
      final page = await document.getPage(i);
      final pageImage = await page.render(width: page.width * 4, height: page.height * 4, quality: 100, format: PdfPageImageFormat.png);
      final Uint8List uint8List = pageImage!.bytes;
      await File(filePath).writeAsBytes(uint8List);
      text += await FlutterTesseractOcr.extractText(filePath, language: "pol", args: {"preserve_interword_spaces": "1", "psm": "4"});
      text += "\n";
    }

    var extractor = TextExtractor();

    var z = extractor.extractDate(text);
    if (z != null) {
      return extractor.extractRecipe(text, z);
    }
    return null;
  }

  void calculateApriori() {
    var apriori = AprioriFactory(1);
    apriori.preprocess(_recipes);
    print(apriori);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            ElevatedButton(
              onPressed: () => calculateApriori(),
              child: const Text("APRIORI"),
            ),
            DataTable(
              columns: const [
                DataColumn(label: Text('Timestamp')),
                DataColumn(label: Text('Ilość pozycji')),
              ],
              rows: _recipes
                  .map((item) => DataRow(
                        cells: [
                          DataCell(Text(item.recipe.time.toString())),
                          DataCell(Text(item.entries.length.toString())),
                        ],
                      ))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: () => _openFileExplorer(context),
              child: const Text("Wybierz plik"),
            )
          ]),
        ),
      ),
    );
  }
}
