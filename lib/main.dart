import 'package:ayat/controllers/player_controller.dart';

import './providers/prevs.dart';
import 'package:flutter/material.dart';
import './pages/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  // runApp(const MyApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => PlayerController()),
        ),
        ChangeNotifierProvider(
          create: ((context) => Prevs()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
