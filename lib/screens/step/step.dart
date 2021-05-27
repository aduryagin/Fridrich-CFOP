import 'package:cfop/screens/step/widgets/algorithm.dart';
import 'package:cfop/screens/step/widgets/stepFilter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

class StepScreen extends StatefulWidget {
  final String title;
  final String id;

  StepScreen({Key? key, required this.title, required this.id})
      : super(key: key);

  @override
  _StepScreenState createState() => _StepScreenState();
}

class _StepScreenState extends State<StepScreen> {
  getLoading() {
    return Center(child: CircularProgressIndicator());
  }

  getError(String error) {
    return Text(error);
  }

  getFilteredSubsteps(List<dynamic> subSteps) {
    final filters = getFilters();
    var filteredSubsteps =
        subSteps.where((item) => filters.contains(item['id'])).toList();
    if (filteredSubsteps.length == 0) filteredSubsteps = subSteps;

    return filteredSubsteps;
  }

  getListView(List<dynamic> subSteps) {
    var filteredSubsteps = getFilteredSubsteps(subSteps);

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 10),
      itemCount: filteredSubsteps.length,
      itemBuilder: itemBuilder(filteredSubsteps),
    );
  }

  bool isInFavorites(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites.contains(id);
  }

  addToFavorites(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final favorites = prefs.getStringList('favorites') ?? [];
    favorites.add(id);
    prefs.setStringList('favorites', favorites);
  }

  removeFromFavorites(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final favorites = prefs.getStringList('favorites') ?? [];
    favorites.remove(id);
    prefs.setStringList('favorites', favorites);
  }

  toggleFavorite(String id) {
    if (isInFavorites(id))
      removeFromFavorites(id);
    else
      addToFavorites(id);
  }

  List<String> getFilters() {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final filters = prefs.getStringList('filters') ?? [];

    return filters;
  }

  addToFilters(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final filters = prefs.getStringList('filters') ?? [];
    filters.add(id);
    prefs.setStringList('filters', filters);
  }

  removeFromFilters(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final filters = prefs.getStringList('filters') ?? [];
    filters.remove(id);
    prefs.setStringList('filters', filters);
  }

  bool isInFilters(String id) {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    final filters = prefs.getStringList('filters') ?? [];
    return filters.contains(id);
  }

  toggleFilters(String id) {
    if (isInFilters(id))
      removeFromFilters(id);
    else
      addToFilters(id);
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

  getScaffold(subSteps, loading) {
    final filteredSubsteps = getFilteredSubsteps(subSteps);
    final filtersApplied = filteredSubsteps.length != subSteps.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        Builder(builder: (BuildContext context) {
          return Stack(children: [
            IconButton(
                icon: Icon(Icons.filter_list),
                tooltip: 'Filters',
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext buildContext) {
                        return GridView.count(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 800
                                    ? 10
                                    : 5,
                            padding: EdgeInsets.all(3),
                            children: subSteps
                                .map<Widget>((item) => StepFilter(
                                      onTap: () {
                                        setState(() {
                                          toggleFilters(item['id']);
                                        });
                                      },
                                      isInFilters: () =>
                                          isInFilters(item['id']),
                                      imageLink: item['image_link'],
                                    ))
                                .toList());
                      });
                }),
            filtersApplied
                ? Positioned(
                    top: 10,
                    right: 7,
                    child: Icon(Icons.brightness_1,
                        size: 12, color: Colors.redAccent),
                  )
                : Container()
          ]);
        })
      ]),
      body: loading ? getLoading() : getListView(subSteps),
    );
  }

  getStepDB(id) async {
    final db = Provider.of<Database>(context);
    List<Map<String, dynamic>> algorithms = await db.rawQuery(
        "select image_link, algorithm, name, a.id, s.id as substep_id from subgroups s left join algorithms a where s.id = a.subgroup_id and s.group_id = $id");

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

        return getScaffold(subSteps, loading);
      },
      future: getStepDB(widget.id),
    );
  }
}
