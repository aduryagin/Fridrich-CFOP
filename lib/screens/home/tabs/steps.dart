import 'package:cfop/screens/step/step.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqlite_api.dart';

class StepsTab extends StatefulWidget {
  StepsTab();

  @override
  _StepsTabState createState() => _StepsTabState();
}

class _StepsTabState extends State<StepsTab> {
  getStepsDB(BuildContext context) async {
    final db = Provider.of<Database>(context);
    List<Map<String, dynamic>> groups =
        await db.rawQuery("select * from groups");

    return groups;
  }

  getListView(List<dynamic> steps) {
    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: itemBuilder(steps),
    );
  }

  itemBuilder(List<dynamic> steps) => (BuildContext context, int index) {
        final item = steps[index];

        return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WillPopScope(
                    onWillPop: () {
                      return Future.value(true);
                    },
                    child: StepScreen(
                        title: item['title'], id: item['id'].toString()));
              }));
            },
            child: ListTile(
              title: Text(item['title']),
              subtitle: Text(item['description']),
            ));
      };

  getLoading() {
    return Center(child: CircularProgressIndicator());
  }

  getError(String error) {
    return Text(error);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none) {
          return Container();
        }

        if (projectSnap.connectionState == ConnectionState.waiting) {
          return getLoading();
        }

        if (projectSnap.connectionState == ConnectionState.done &&
            projectSnap.hasError) {
          return getError(projectSnap.error.toString());
        }

        return getListView(projectSnap.data as List<dynamic>);
      },
      future: getStepsDB(context),
    );
  }
}
