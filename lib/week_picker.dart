import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekDropDown extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final Color backColor;

  WeekDropDown({required this.onChanged, required this.backColor});

  @override
  _WeekDropDownState createState() => _WeekDropDownState();
}

class _WeekDropDownState extends State<WeekDropDown> {
  List<String> weeks = [];
  String selectedWeek = "";

  @override
  void initState() {
    super.initState();
    populateWeeks();
    selectedWeek = getFormattedCurrentWeek();
  }

  void populateWeeks() {
    DateTime now = DateTime.now();
    DateTime yearStart = DateTime(now.year, 1, 1);

    while (yearStart.year == now.year) {
      DateTime monday =
          yearStart.subtract(Duration(days: yearStart.weekday - 1));
      DateTime sunday = monday.add(Duration(days: 6));

      String formattedMonday = DateFormat('yyyy / MM / dd').format(monday);
      String formattedSunday = DateFormat('yyyy / MM / dd').format(sunday);
      weeks.add("$formattedMonday - $formattedSunday");

      yearStart = yearStart.add(Duration(days: 7));
    }
  }

  String getFormattedCurrentWeek() {
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    DateTime sunday = monday.add(Duration(days: 6));

    String formattedMonday = DateFormat('yyyy / MM / dd').format(monday);
    String formattedSunday = DateFormat('yyyy / MM / dd').format(sunday);

    return "$formattedMonday - $formattedSunday";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.backColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.backColor),
          ),
          child: DropdownButton<String>(
            value: selectedWeek,
            underline: SizedBox(), // Removes the default underline
            onChanged: (String? newValue) {
              setState(() {
                selectedWeek = newValue!;
              });
              widget.onChanged(
                  selectedWeek); // Notify the parent about the change
            },
            items: weeks.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
