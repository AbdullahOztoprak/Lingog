import 'package:flutter/material.dart';
import 'package:lingogame/important/controller.dart';
import 'package:lingogame/important/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => Controller(wordLength: 5)), // Default 5 harf
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Controller()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lingog',
        home: HomePage(), //
      ),
    );
  }
}
