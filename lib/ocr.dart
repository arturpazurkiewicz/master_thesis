import 'dart:io';
import 'dart:typed_data';

import 'package:biedronka_extractor/text_extractor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import 'model/recipe_full.dart';

class OCR {
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
}
