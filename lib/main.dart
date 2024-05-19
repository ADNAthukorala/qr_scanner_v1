import 'package:flutter/material.dart';
import 'package:qr_scanner/qr_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        /// App bars theme
        appBarTheme: const AppBarTheme(
          color: kAppThemeColor,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: kWhiteThemeColor,
            fontSize: 22.0,
          ),
        ),

        /// Elevated buttons theme
        elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(kAppThemeColor),
          foregroundColor: WidgetStatePropertyAll(kWhiteThemeColor),
          fixedSize: WidgetStatePropertyAll(Size.fromHeight(60.0)),
        )),

        /// Icon buttons theme
        iconButtonTheme: const IconButtonThemeData(
            style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(kAppThemeColor),
        )),
        colorScheme: ColorScheme.fromSeed(seedColor: kAppThemeColor),
        useMaterial3: true,
      ),
      home: const QRScannerScreen(),
    );
  }
}
