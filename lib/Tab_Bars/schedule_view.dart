import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

import '../Constants/listConstants.dart' as co;
import '../duration.dart';
import '../schedule.dart';
import '../week_picker.dart';

class ScheduleView extends StatefulWidget {
  List<Schedule> regularSchedule = []; // List to store Regular Schedule
  List<TextEditingController> startTimeControllers = [];
  List<TextEditingController> endTimeControllers = [];
  final String CMSID;
  final bool isReading;
  final bool isDoingMath;
  final String name;

  ScheduleView(
      this.regularSchedule,
      this.endTimeControllers,
      this.startTimeControllers,
      this.CMSID,
      this.isReading,
      this.isDoingMath,
      this.name);

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  String subject = '';

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedule details saved successfully.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFailMessage(error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save regular schedule: $error'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedWeek =
      ''; // Global variable to store the selected week details

  var startTime;
  var endTime;

  String calculateDuration(endTimeStr, startTimeStr) {
    Duration? duration;
    if (endTime != null && startTime != null) {
      final endTime = DateFormat.Hm().parse(endTimeStr!);
      final startTime = DateFormat.Hm().parse(startTimeStr!);
      final difference = endTime.difference(startTime);
      duration = Duration(
          hours: difference.inHours,
          minutes: difference.inMinutes.remainder(60));
    } else {
      duration = null;
    }

    return '${duration != null ? duration!.inMinutes : 'N/A'}';
  }

  String calculateEndTime(String startTime, int durationMinutes) {
    // Define a date format to parse the input time string.
    final timeFormat = DateFormat('hh:mm a');

    // Parse the start time string into a DateTime object.
    final startTimeDateTime = timeFormat.parse(startTime);

    // Calculate the end time by adding the duration in minutes to the start time.
    final endTimeDateTime =
        startTimeDateTime.add(Duration(minutes: durationMinutes));

    // Format the end time as a string in the desired format.
    final endTimeString = timeFormat.format(endTimeDateTime);

    return endTimeString;
  }

  void _saveScheduleToFirestore() async {
    final firestore = Firestore.instance;
    final regScheduleDetailsCollection = firestore
        .collection('Students')
        .document(widget.CMSID)
        .collection("Regular Schedule");

    // Delete the existing "Regular Schedule" collection
    await regScheduleDetailsCollection.get().then((snapshot) {
      for (var doc in snapshot) {
        doc.reference.delete();
      }
      print('Existing "Regular Schedule" collection deleted');
    }).catchError((error) {
      print('Failed to delete existing collection: $error');
    });

    // Create a new "Regular Schedule" collection
    for (var regSchedule in widget.regularSchedule) {
      await regScheduleDetailsCollection.add({
        'day': regSchedule.day,
        'startTime': regSchedule.startTime,
        'endTime': regSchedule.endTime,
        'location': regSchedule.location,
        'duration': regSchedule.timediff,
        'week': selectedWeek,
      }).then((value) {
        _showSuccessMessage();
        print('Regular Schedule saved to Firestore');
      }).catchError((error) {
        _showFailMessage(error);
        print('Failed to save regular schedule: $error');
      });
    }
  }

  void _saveMeToFirestore() async {
    final firestore = Firestore.instance;
    final regScheduleDetailsCollection = firestore.collection('Schedule');

    // Create a new "Regular Schedule" collection
    for (var regSchedule in widget.regularSchedule) {
      await regScheduleDetailsCollection.add({
        'day': regSchedule.day,
        'startTime': regSchedule.startTime,
        'location': regSchedule.location,
        'cmsID': widget.CMSID,
        'week': selectedWeek,
        'name': widget.name,
        'subject': subject,
        'timediff': int.tryParse(regSchedule.timediff),
      }).then((value) {
        _showSuccessMessage();
        print('Regular Schedule saved to Firestore');
      }).catchError((error) {
        _showFailMessage(error);
        print('Failed to save regular schedule: $error');
      });
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
  void initState() {
    // TODO: implement initState
    if (widget.isReading) {
      subject = "R";
    } else {
      subject = "M";
    }
    selectedWeek = getFormattedCurrentWeek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: WeekDropDown(
                onChanged: (String newValue) {
                  setState(() {
                    selectedWeek = newValue;
                  });
                },
                backColor: Colors.blue,
              ),
            ),
            Table(
              defaultColumnWidth: IntrinsicColumnWidth(),
              border: TableBorder.all(
                color: Colors.blue,
                width: 1.0,
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.blue[300],
                  ),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Day',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Start',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'End',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Class',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Minutes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                for (var index = 0;
                    index < widget.regularSchedule.length;
                    index++)
                  TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: widget.regularSchedule[index].day,
                              items: co.dayOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  widget.regularSchedule[index].day = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            child: Center(
                              child: TextField(
                                controller: widget.startTimeControllers[index],
                                decoration: InputDecoration(
                                  labelText: "Enter Time",
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                readOnly: true,
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    initialTime: TimeOfDay.now(),
                                    context: context,
                                  );

                                  if (pickedTime != null) {
                                    print(pickedTime
                                        .format(context)); // Output: 10:51 PM
                                    String formattedTime =
                                        pickedTime.format(context).toString();
                                    var df = DateFormat("h:mm a");
                                    var dt =
                                        df.parse(pickedTime!.format(context));

                                    setState(() {
                                      startTime =
                                          DateFormat('HH:mm').format(dt);
                                      widget.startTimeControllers[index].text =
                                          formattedTime;
                                      widget.regularSchedule[index].startTime =
                                          formattedTime;
                                    });
                                  } else {
                                    print("Time is not selected");
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextField(
                                  controller: widget.endTimeControllers[index],
                                  decoration: InputDecoration(
                                    labelText: "Enter Time",
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );

                                    if (pickedTime != null) {
                                      print(pickedTime
                                          .format(context)); // Output: 10:51 PM
                                      String formattedTime =
                                          pickedTime.format(context).toString();
                                      var df = DateFormat("h:mm a");
                                      var dt =
                                          df.parse(pickedTime!.format(context));

                                      setState(() {
                                        endTime =
                                            DateFormat('HH:mm').format(dt);
                                        widget.endTimeControllers[index].text =
                                            formattedTime;
                                        widget.regularSchedule[index].endTime =
                                            formattedTime;
                                        widget.regularSchedule[index].timediff =
                                            calculateDuration(
                                                endTime, startTime);
                                      });
                                    } else {
                                      print("Time is not selected");
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            widget.isReading
                                ? 'Reading'
                                : (widget.isDoingMath ? 'Math' : 'None'),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: widget.regularSchedule[index].location,
                              items: co.locations
                                  .toSet()
                                  .toList()
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  widget.regularSchedule[index].location =
                                      newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ScheduleDuration(
                              endTime: endTime,
                              startTime: startTime,
                              timediff: widget.regularSchedule[index].timediff),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: InkWell(
                            onTap: () {
                              // Delete row functionality
                              setState(() {
                                widget.regularSchedule.removeAt(index);
                                widget.startTimeControllers.remove(index);
                                widget.endTimeControllers.remove(index);
                              });
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Handle button click to add a row
                setState(() {
                  widget.regularSchedule.add(
                    Schedule(
                      day: 'Monday',
                      startTime: 'New Start Time',
                      endTime: 'New End Time',
                      location: co.locations[0],
                      timediff: 'N/A',
                    ),
                  );
                  widget.startTimeControllers
                      .add(TextEditingController(text: ""));
                  widget.endTimeControllers
                      .add(TextEditingController(text: ""));
                });
              },
              child: Text('Add Row'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle button click to add a row
                setState(() {
                  _saveScheduleToFirestore();
                  _saveMeToFirestore();
                });
              },
              child: Text('Save Details'),
            ),
          ],
        ),
      ),
    );
  }
}
