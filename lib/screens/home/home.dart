import 'package:cfop/constants.dart';
import 'package:cfop/screens/home/tabs/favorites.dart';
import 'package:cfop/screens/home/tabs/steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  static List<Function> tabs = [
    () => StepsTab(),
    () => FavoritesTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(APP_NAME), actions: [
        TextButton(
          onPressed: () async {
            final url = 'https://github.com/aduryagin/Fridrich-CFOP';
            if (await canLaunch(url)) {
              await launch(url);
            }
          },
          child: Text(
            "Source Code",
            style: TextStyle(color: Colors.white),
          ),
        )
      ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Steps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
      body: tabs.elementAt(selectedIndex)(),
    );
  }
}
