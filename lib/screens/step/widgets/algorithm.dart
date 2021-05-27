import 'package:flutter/material.dart';

class Algorithm extends StatefulWidget {
  final Function onTap;
  final String algorithm;
  final Function isInFavorites;

  Algorithm(
      {Key? key,
      required this.onTap,
      required this.algorithm,
      required this.isInFavorites})
      : super(key: key);

  @override
  _AlgorithmState createState() => _AlgorithmState();
}

class _AlgorithmState extends State<Algorithm> {
  bool isInFavorites = false;

  @override
  void initState() {
    super.initState();

    isInFavorites = widget.isInFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
          onTap: () {
            setState(() {
              isInFavorites = !isInFavorites;
            });

            widget.onTap();
          },
          title: Text(widget.algorithm),
          trailing: Icon(
            Icons.favorite,
            color: isInFavorites ? Colors.blue : Colors.black38,
          ),
        ),
        decoration: new BoxDecoration(
            border: new Border(bottom: new BorderSide(color: Colors.black12))));
  }
}
