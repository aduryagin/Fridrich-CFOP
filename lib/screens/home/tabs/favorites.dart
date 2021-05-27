import 'package:cfop/screens/step/widgets/algorithm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

class FavoritesTab extends StatefulWidget {
  FavoritesTab({Key? key}) : super(key: key);

  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  getError(String error) {
    return Text(error);
  }

  getFavoritesIDs() {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites;
  }

  addToFavorites(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final favorites = prefs.getStringList('favorites') ?? [];
    favorites.add(id);
    prefs.setStringList('favorites', favorites);
  }

  bool isInFavorites(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites.contains(id);
  }

  toggleFavorite(String id) {
    if (isInFavorites(id))
      removeFromFavorites(id);
    else
      addToFavorites(id);
  }

  removeFromFavorites(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final favorites = prefs.getStringList('favorites') ?? [];
    favorites.remove(id);
    prefs.setStringList('favorites', favorites);
  }

  getLoading() {
    return Center(child: CircularProgressIndicator());
  }

  getListView(List<dynamic> subSteps) {
    if (subSteps.length == 0)
      return Padding(
          padding: EdgeInsets.all(15), child: Text('Nothing found...'));

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 10),
      itemCount: subSteps.length,
      itemBuilder: itemBuilder(subSteps),
    );
  }

  itemBuilder(List<dynamic> subSteps) => (BuildContext context, int index) {
        final subStep = subSteps[index];
        final List<Widget> column = [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Image(
                      width: 120,
                      fit: BoxFit.cover,
                      image: AssetImage(subStep['image_link']))),
              Text('Name: ${subStep['name']}')
            ],
          ),
        ];
        column.addAll(subStep['algorithms']
            .map<Widget>((item) => Algorithm(
                  algorithm: item['algorithm'],
                  onTap: () {
                    toggleFavorite(item['id']);
                  },
                  isInFavorites: () => isInFavorites(item['id']),
                ))
            .toList());

        return Padding(
            padding: EdgeInsets.only(top: 15, left: 10, right: 10),
            child: Column(children: column));
      };

  getFavoritesDB() async {
    final favoritesIDs = getFavoritesIDs()
        .toString()
        .replaceFirst('[', '(')
        .replaceFirst(']', ')');
    final db = Provider.of<Database>(context);

    List<Map<String, dynamic>> algorithms = await db.rawQuery(
        "select s.image_link, a.algorithm, s.name, a.id, s.id as substep_id from algorithms a left join subgroups s where s.id = a.subgroup_id and a.id IN $favoritesIDs");

    List<Map> normalizedSubgroups = [];
    algorithms.forEach((algorithm) {
      final existSubgroup = normalizedSubgroups
          .where((item) => item['name'] == algorithm['name']);
      final item = {
        'id': algorithm['id'].toString(),
        'algorithm': algorithm['algorithm']
      };

      if (existSubgroup.isNotEmpty) {
        existSubgroup.first['algorithms'].add(item);
      } else {
        normalizedSubgroups.add({
          'id': algorithm['substep_id'].toString(),
          'name': algorithm['name'],
          'image_link':
              algorithm['image_link'].replaceAll('/static/', 'assets/'),
          'algorithms': [item],
        });
      }
    });

    return normalizedSubgroups;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none) {
          return Container();
        }

        if (projectSnap.connectionState == ConnectionState.done &&
            projectSnap.hasError) {
          return getError(projectSnap.error.toString());
        }

        final loading = projectSnap.connectionState == ConnectionState.waiting;
        final subSteps = !loading ? projectSnap.data : [];

        return loading ? getLoading() : getListView(subSteps as List<dynamic>);
      },
      future: getFavoritesDB(),
    );
  }
}
