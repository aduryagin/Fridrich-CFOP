import 'package:flutter/material.dart';

class StepFilter extends StatefulWidget {
  final String imageLink;
  final Function isInFilters;
  final Function onTap;

  StepFilter(
      {required this.imageLink,
      required this.isInFilters,
      required this.onTap});

  @override
  _StepFilterState createState() => _StepFilterState();
}

class _StepFilterState extends State<StepFilter> {
  bool isInFilters = false;

  @override
  void initState() {
    super.initState();

    isInFilters = widget.isInFilters();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            isInFilters = !isInFilters;
          });

          widget.onTap();
        },
        child: Padding(
            padding: EdgeInsets.all(3),
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 4,
                      color: isInFilters ? Colors.blue : Colors.transparent),
                ),
                child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Image(
                        width: 50,
                        fit: BoxFit.cover,
                        image: AssetImage(widget.imageLink))))));
  }
}
