import 'package:biedronka_extractor/screens/home_screen.dart';
import 'package:biedronka_extractor/screens/shopping_screen.dart';
import 'package:biedronka_extractor/screens/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

main() {
  runApp(MaterialApp(home: MyApp(), localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ], supportedLocales: const [
    Locale('en'),
    Locale('pl')
  ]));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF OCR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/transactions':
            return MaterialPageRoute(builder: (_) => const TransactionScreen());
          case '/lists':
            return MaterialPageRoute(builder: (_) => const ShoppingScreen());
          default:
            return null;
        }
      },
    );
  }
}
