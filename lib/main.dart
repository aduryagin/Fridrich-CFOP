import 'dart:io';

import 'package:cfop/constants.dart';
import 'package:cfop/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init db

  final dbDir = await getDatabasesPath();
  final dbPath = join(dbDir, "cfop.db");
  final exists = await databaseExists(dbPath);

  if (!exists) {
    try {
      await Directory(dirname(dbPath)).create(recursive: true);
    } catch (error) {}

    ByteData data =
        await rootBundle.load(join("assets", "database", "dump.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes);
  }

  final db = await openDatabase(dbPath);

  // shared prefs

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // render

  runApp(MultiProvider(
    providers: [
      Provider.value(value: db),
      Provider.value(value: prefs),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(),
    );
  }
}
