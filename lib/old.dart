import 'package:biedronka_extractor/presentation/data_controllers.dart';
import 'package:biedronka_extractor/presentation/datacontroller_provider.dart';
import 'package:biedronka_extractor/presentation/home_screen.dart';
import 'package:biedronka_extractor/presentation/theme/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'data/helpers/auth_helper.dart';
import 'data/repository_impl.dart';
import 'ocr_home_page.dart';

void main() {
  runApp(MyApp2());
}

class MyApp2 extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tesseract Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OCRHomePage(title: 'Tesseract Demo'),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>?>(
      future: AuthHelper.authenticate(),
      builder: (context, snapshot) {
        final headers = snapshot.data;

        if (headers != null) {
          headers.addAll(
            {
              "Accept": "application/json",
              "Access-Control-Allow-Origin": "*",
              "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, DELETE, OPTIONS",
              "Access-Control-Allow-Headers": "Origin, Content-Type, X-Auth-Token, X-Requested-With"
            },
          );
        }

        final repository = RepositoryImpl(Dio(
          BaseOptions(
            headers: headers,
          ),
        ));
        return MaterialApp(
          title: 'Finances Tracker',
          theme: ThemeData(
            primaryColor: AppColor.primaryColor,
            bottomSheetTheme: BottomSheetThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              modalBackgroundColor: AppColor.primaryContainer,
              elevation: 5.0,
            ),
            colorScheme: ColorScheme.light(
              secondary: AppColor.secondary,
              tertiary: AppColor.tertiary,
              primaryContainer: AppColor.primaryContainer,
              tertiaryContainer: AppColor.tertiaryContainer,
            ),
          ),
          home: headers == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : DataControllerProvider<EntryDataController>(
                  dataController: EntryDataController(repository),
                  child: DataControllerProvider<TargetDataController>(
                    dataController: TargetDataController(repository),
                    child: const HomeScreen(),
                  ),
                ),
        );
      },
    );
  }
}
