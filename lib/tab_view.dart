import 'package:firedart/firestore/firestore.dart';
import 'package:firedart/firestore/models.dart';
import 'package:flutter/material.dart';
import 'package:nala_attendance/enrollment.dart';
import 'package:nala_attendance/guardian.dart';
import 'package:nala_attendance/schedule.dart';
import 'package:intl/intl.dart';
import 'Attendance.dart';
import 'duration.dart';
import 'package:table_calendar/table_calendar.dart';

class TabbedContainer extends StatefulWidget {
  final List<Guardian> guardians;
  final bool isReading;
  final bool isDoingMath;
  final String CMSID;

  TabbedContainer(this.guardians, this.isReading, this.isDoingMath, this.CMSID);

  @override
  _TabbedContainerState createState() => _TabbedContainerState();
}

class _TabbedContainerState extends State<TabbedContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var startTime;
  var endTime;
  var timeDiff;
  int _selectedIndex = 0;

  List<TextEditingController> startTimeControllers = [];
  List<TextEditingController> endTimeControllers = [];

  List<Schedule> regularSchedule = []; // List to store Regular Schedule
  List<Schedule> overideSchedule = []; // List to store Regular Schedule

  List<Enrollment> enrollments = [];
 // final CollectionReference enrollmentRef = Firestore.instance.collection('Students').document(widget.CMSID).collection("Enrollments");
  List<String> dayOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<Attendance> attendanceList = [];
  String selectedWeek = ''; // Global variable to store the selected week details

  String calculateDuration(endTimeStr,startTimeStr) {
    Duration? duration;
    if (endTime != null && startTime != null) {
      final endTime = DateFormat.Hm().parse(endTimeStr!);
      final startTime = DateFormat.Hm().parse(startTimeStr!);
      final difference = endTime.difference(startTime);
      duration = Duration(hours: difference.inHours, minutes: difference.inMinutes.remainder(60));
    } else {
      duration = null;
    }

    return '${duration != null ? duration!.inMinutes : 'N/A'}';
  }



  void getEnrollments(String cmsStudentId) async {

    final firestore = Firestore.instance;
    final enrollmentDetailsCollection = firestore.collection('Students').document(widget.CMSID).collection("Enrollments");


    try {
      final studentlist = await enrollmentDetailsCollection.get();

      for (final data in studentlist) {


          setState(() {

            final enrollment = Enrollment(

              Class: data['Class'],
              startDate: data['StartDate'],
              endDate: data['EndDate'],

            );

              enrollments = [];
              enrollments.add(enrollment);

          });


      }
    } catch (e) {
      print(e.toString());
    }


  }

  void getregSchedule(String cmsStudentId) async {

    final firestore = Firestore.instance;
    final regularDetailsCollection = firestore.collection('Students').document(widget.CMSID).collection("Regular Schedule");

    print("came here");

    try {
      final studentlist = await regularDetailsCollection.get();

      print(studentlist);
      for (final data in studentlist) {




          final schedule = Schedule(
              day: data['day'],
              startTime: data['startTime'],
              endTime: data['endTime'],
              location: data['location'],
              timediff: data['duration'],




          );

          startTimeControllers.add(TextEditingController(text: data['startTime']));
          endTimeControllers.add(TextEditingController(text: data['endTime']));

          regularSchedule.add(schedule);




      }
    } catch (e) {
      print(e.toString());
    }


  }

  void _saveOverScheduleToFirestore() async {
    final firestore = Firestore.instance;
    final overScheduleDetailsCollection =
    firestore.collection('Students').document(widget.CMSID).collection("Overide Schedule");

    // Delete the existing "Regular Schedule" collection
    await overScheduleDetailsCollection.get().then((snapshot) {
      for (var doc in snapshot) {
        doc.reference.delete();
      }
      print('Existing "Regular Schedule" collection deleted');
    }).catchError((error) {
      print('Failed to delete existing collection: $error');
    });

    // Create a new "Regular Schedule" collection
    for (var regSchedule in regularSchedule) {
      await overScheduleDetailsCollection.add({
        'week': selectedWeek,
        'day': regSchedule.day,
        'startTime': regSchedule.startTime,
        'endTime': regSchedule.endTime,
        'location': regSchedule.location,
        'duration': regSchedule.timediff,
      }).then((value) {
        print('Regular Schedule saved to Firestore');
      }).catchError((error) {
        print('Failed to save regular schedule: $error');
      });
    }
  }
  void _saveScheduleToFirestore() async {
    final firestore = Firestore.instance;
    final regScheduleDetailsCollection =
    firestore.collection('Students').document(widget.CMSID).collection("Regular Schedule");

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
    for (var regSchedule in regularSchedule) {
      await regScheduleDetailsCollection.add({
        'day': regSchedule.day,
        'startTime': regSchedule.startTime,
        'endTime': regSchedule.endTime,
        'location': regSchedule.location,
        'duration': regSchedule.timediff,
      }).then((value) {
        print('Regular Schedule saved to Firestore');
      }).catchError((error) {
        print('Failed to save regular schedule: $error');
      });
    }
  }


  void getStudents() async {
    List<Attendance> attendancelist = [];
    final CollectionReference studentsRef = Firestore.instance.collection("Students").document(widget.CMSID).collection("Attendance");

    try {
      final studentlist = await studentsRef.get();
      print(studentlist);

      for (final data in studentlist) {
        final student = Attendance(

          dateIn: data['dTimeIn'],
          dateOut: data['dTimeOut'],
          Class: 'math',
          notes: '',
        );

        attendancelist.add(student);
      }
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      if (mounted) {
        attendanceList = attendancelist;

      }
    });

  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      _selectedIndex = _tabController.index;
    });


        setState(() {
          regularSchedule=[];
          getregSchedule(widget.CMSID);


        });


        getStudents();
        getEnrollments(widget.CMSID);



        // Initialize the controllers for the existing rows in regularSchedule
        for (int i = 0; i < regularSchedule.length; i++) {
          startTimeControllers.add(TextEditingController(text: regularSchedule[i].startTime));
          endTimeControllers.add(TextEditingController(text: regularSchedule[i].endTime));
        }


        


    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void addRegularScheduleRow() {
    setState(() {
      if (regularSchedule.isEmpty) {
        regularSchedule.add(
          Schedule(
            day: 'Monday',
            startTime: '4:30 PM',
            endTime: '5:30 PM',
            location: 'Classroom A',
            timediff: 'N/A',

          ),
        );
        startTimeControllers.add(TextEditingController(text: ""));
        endTimeControllers.add(TextEditingController(text: ""));
      }

    });
  }




  void deleteRegularScheduleRow(int index) {
    setState(() {
      regularSchedule.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 20,
            color: Colors.blue, // Customize the container background color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(0);
                    _selectedIndex=0;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    color: _selectedIndex == 0 ? Colors.white : Colors.transparent,
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: _selectedIndex == 0 ? Colors.blue : Colors.white,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(1);
                    _selectedIndex = 1;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    color: _selectedIndex == 1 ? Colors.white : Colors.transparent,
                    child: Text(
                      'Schedule',
                      style: TextStyle(
                        color: _selectedIndex == 1 ? Colors.blue : Colors.white,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(2);
                    _selectedIndex = 2;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    color: _selectedIndex == 2 ? Colors.white : Colors.transparent,
                    child: Text(
                      'Enrollment History',
                      style: TextStyle(
                        color: _selectedIndex == 2 ? Colors.blue : Colors.white,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(3);
                    _selectedIndex = 3;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    color: _selectedIndex == 3 ? Colors.white : Colors.transparent,
                    child: Text(
                      'Attendance',
                      style: TextStyle(
                        color: _selectedIndex == 3 ? Colors.blue : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  child: ListView(
                    children: [
                      Text(
                        'Student CMS Contact(s)',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Table(
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
                                    'Relation',
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
                                    'First Name',
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
                                    'Last Name',
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
                                    'Email Address',
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
                                    'Home Phone',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          for (var index = 0; index < widget.guardians.length; index++)
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(widget.guardians[index].relation),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(widget.guardians[index].firstName),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(widget.guardians[index].lastName),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(widget.guardians[index].email),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(widget.guardians[index].phone),
                                  ),
                                ),
                              ],
                            ),
                          // Add more rows as needed
                        ],
                      ),
                    ],
                  ),
                ),
                DefaultTabController(
                  length: 2, // Number of sub-tabs inside Schedule tab
                  child: Scaffold(
                    appBar: TabBar(
                      tabs: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _tabController.animateTo(1);
                            });

                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16), // Adjust the padding to reduce the height

                            child: Text(
                              'Regular Schedule',
                              style: TextStyle(
                                color: Colors.blue,
                              ),

                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _tabController.animateTo(0);
                            });

                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16), // Adjust the padding to reduce the height

                            child: Text(
                              'Override Schedule',
                              style: TextStyle(
                                color: Colors.blue,
                              ),

                            ),
                          ),
                        ),
                        // Tab(text: 'Regular Schedule'),
                        // Tab(text: 'Schedule Overrides'),
                      ],
                    ),
                    body: TabBarView(
                      children: [
                        Container(
                          child: ListView(
                            children: [
                              Table(
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
                                  for (var index = 0; index < regularSchedule.length; index++)
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: regularSchedule[index].day,
                                                items: dayOptions.map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    regularSchedule[index].day = newValue!;

                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              child: Center(
                                                child: TextField(
                                                  controller: startTimeControllers[index],
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
                                                      print(pickedTime.format(context)); // Output: 10:51 PM
                                                      String formattedTime =
                                                      pickedTime.format(context).toString();
                                                      var df = DateFormat("h:mm a");
                                                      var dt = df.parse(pickedTime!.format(context));


                                                      setState(() {
                                                        startTime =  DateFormat('HH:mm').format(dt);
                                                        startTimeControllers[index].text = formattedTime;
                                                        regularSchedule[index].startTime= formattedTime;
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              child: Center(
                                                child: TextField(
                                                  controller: endTimeControllers[index],
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
                                                      print(pickedTime.format(context)); // Output: 10:51 PM
                                                      String formattedTime =
                                                      pickedTime.format(context).toString();
                                                      var df = DateFormat("h:mm a");
                                                      var dt = df.parse(pickedTime!.format(context));





                                                      setState(() {
                                                        endTime =  DateFormat('HH:mm').format(dt);
                                                        endTimeControllers[index].text = formattedTime;
                                                        regularSchedule[index].endTime = formattedTime;
                                                        regularSchedule[index].timediff = calculateDuration(endTime,startTime);

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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              widget.isReading ? 'Reading' : (widget.isDoingMath ? 'Math' : 'None'),
                                            )
                                            ,
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(

                                              initialValue: regularSchedule[index].location,

                                              onChanged: (value) {
                                                setState(() {
                                                  regularSchedule[index].location = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),

                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ScheduleDuration(endTime: endTime, startTime: startTime, timediff: regularSchedule[index].timediff ),


                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () {
                                                // Delete row functionality
                                                setState(() {
                                                  regularSchedule.removeAt(index);
                                                  startTimeControllers.remove(index);
                                                  endTimeControllers.remove(index);
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
                                    regularSchedule.add(
                                      Schedule(
                                        day: 'Monday',
                                        startTime: 'New Start Time',
                                        endTime: 'New End Time',
                                        location: 'New Location',
                                        timediff: 'N/A',


                                      ),
                                    );
                                    startTimeControllers.add(TextEditingController(text: ""));
                                    endTimeControllers.add(TextEditingController(text: ""));
                                  });
                                },
                                child: Text('Add Row'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle button click to add a row
                                  _saveScheduleToFirestore();
                                },
                                child: Text('Save Details'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: ListView(
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: TableCalendar(
                                    firstDay: DateTime.now(),
                                    lastDay: DateTime.now().add(Duration(days: 7)), // Set the last day as a week from the current day
                                    focusedDay: DateTime.now(),
                                    calendarFormat: CalendarFormat.week, // Set the calendar format to week view
                                    onDaySelected: (selectedDay, focusedDay) {
                                      // Handle day selection if needed
                                    },
                                    onFormatChanged: (format) {
                                      // Handle format change if needed
                                    },
                                    onPageChanged: (focusedDay) {
                                      // Update the selected week when the page changes
                                      final newWeek = DateFormat('MMMM y').format(focusedDay) +
                                          ' ' +
                                          DateFormat('d').format(focusedDay) +
                                          '-' +
                                          DateFormat('d').format(focusedDay.add(Duration(days: 6)));

                                      if (newWeek != selectedWeek) {

                                          selectedWeek = newWeek;
                                          print(selectedWeek);

                                      }
                                    },
                                  ),
                                ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       border: Border.all(
                              //         color: Colors.blue,
                              //         width: 2.0,
                              //       ),
                              //     ),
                              //     child: TableCalendar(
                              //       firstDay: DateTime.now(),
                              //       lastDay: DateTime.now().add(Duration(days: 7)), // Set the last day as a week from the current day
                              //       focusedDay: DateTime.now(),
                              //       calendarFormat: CalendarFormat.week, // Set the calendar format to week view
                              //       onDaySelected: (selectedDay, focusedDay) {
                              //         // Handle day selection if needed
                              //       },
                              //       onFormatChanged: (format) {
                              //         // Handle format change if needed
                              //       },
                              //
                              //       onPageChanged: (focusedDay) {
                              //         // Update the selected week when the page changes
                              //         setState(() {
                              //           selectedWeek = DateFormat('MMMM y').format(focusedDay) +
                              //               ' ' +
                              //               DateFormat('d').format(focusedDay) +
                              //               '-' +
                              //               DateFormat('d').format(focusedDay.add(Duration(days: 6)));
                              //
                              //           print(selectedWeek);
                              //         });
                              //       },
                              //     ),
                              //   ),
                              // ),


                              Table(
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
                                  for (var index = 0; index < regularSchedule.length; index++)
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: regularSchedule[index].day,
                                                items: dayOptions.map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    regularSchedule[index].day = newValue!;

                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              child: Center(
                                                child: TextField(
                                                  controller: startTimeControllers[index],
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
                                                      print(pickedTime.format(context)); // Output: 10:51 PM
                                                      String formattedTime =
                                                      pickedTime.format(context).toString();
                                                      var df = DateFormat("h:mm a");
                                                      var dt = df.parse(pickedTime!.format(context));


                                                      setState(() {
                                                        startTime =  DateFormat('HH:mm').format(dt);
                                                        startTimeControllers[index].text = formattedTime;
                                                        regularSchedule[index].startTime= formattedTime;
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              child: Center(
                                                child: TextField(
                                                  controller: endTimeControllers[index],
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
                                                      print(pickedTime.format(context)); // Output: 10:51 PM
                                                      String formattedTime =
                                                      pickedTime.format(context).toString();
                                                      var df = DateFormat("h:mm a");
                                                      var dt = df.parse(pickedTime!.format(context));





                                                      setState(() {
                                                        endTime =  DateFormat('HH:mm').format(dt);
                                                        endTimeControllers[index].text = formattedTime;
                                                        regularSchedule[index].endTime = formattedTime;
                                                        regularSchedule[index].timediff = calculateDuration(endTime,startTime);

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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              widget.isReading ? 'Reading' : (widget.isDoingMath ? 'Math' : 'None'),
                                            )
                                            ,
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(

                                              initialValue: regularSchedule[index].location,

                                              onChanged: (value) {
                                                setState(() {
                                                  regularSchedule[index].location = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),

                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ScheduleDuration(endTime: endTime, startTime: startTime, timediff: regularSchedule[index].timediff ),


                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () {
                                                // Delete row functionality
                                                setState(() {
                                                  regularSchedule.removeAt(index);
                                                  startTimeControllers.remove(index);
                                                  endTimeControllers.remove(index);
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
                                    regularSchedule.add(
                                      Schedule(
                                        day: 'Monday',
                                        startTime: 'New Start Time',
                                        endTime: 'New End Time',
                                        location: 'New Location',
                                        timediff: 'N/A',


                                      ),
                                    );
                                    startTimeControllers.add(TextEditingController(text: ""));
                                    endTimeControllers.add(TextEditingController(text: ""));
                                  });
                                },
                                child: Text('Add Row'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle button click to add a row
                                  _saveOverScheduleToFirestore();
                                },
                                child: Text('Save Details'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ListView(
                    children: [

                      SizedBox(
                        height: 10,
                      ),
                      Table(
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
                                    'Class name',
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
                                    'Start Date',
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
                                    'End Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),


                            ],
                          ),
                          for (var index = 0; index < enrollments.length; index++)
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(enrollments[index].Class),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(enrollments[index].startDate),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(enrollments[index].endDate),
                                  ),
                                ),

                              ],
                            ),
                          // Add more rows as needed
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: ListView(
                    children: [

                      SizedBox(
                        height: 10,
                      ),
                      Table(
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
                                    'Date/Time In',
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
                                    'Date/Time Out',
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
                                    'Class Name',
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
                                    'Students Notes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),


                            ],
                          ),
                          for (var index = 0; index < attendanceList.length; index++)
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(attendanceList[index].dateIn),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(attendanceList[index].dateOut),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(attendanceList[index].Class),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(attendanceList[index].notes),
                                  ),
                                ),

                              ],
                            ),
                          // Add more rows as needed
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

