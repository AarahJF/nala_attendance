import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:firedart/firestore/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomeScreen extends StatefulWidget {


  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = '';
  CollectionReference studentNames = Firestore.instance.collection('Students');
  int greenCountM = 0;
  int yellowCountM = 0;
  int redCountM = 0;
  int greenCountR = 0;
  int yellowCountR = 0;
  int redCountR = 0;

  List<DisplayStudent> mathStudents = [];
  List<DisplayStudent> readStudents = [];
  List<StudentRecord> studentRecords = [];

  @override
  void initState() {
    super.initState();
    restoreDataFromCsv();
  }

  @override
  void dispose() {
    saveDataToCsv();
    super.dispose();
  }



  void _saveAttendanceToFirestore(String id,String inTime, String outTime ) {

      print("came here");

    final CollectionReference studentsRef = Firestore.instance.collection("Students").document(id).collection("Attendance");

    studentsRef.add({
      'dTimeIn': inTime,
      'dTimeOut': outTime,

    }).then((value) {
      print('Enrollment saved to Firestore');
    }).catchError((error) {
      print('Failed to save guardian: $error');
    });

  }

  Future<void> restoreDataFromCsv() async {
    final csvData = await CsvHelper.readCsv('data.csv');
    for (final row in csvData) {
      final DateTime storedTime = DateTime.parse(row[4]); // Parse the stored time from the CSV
      final DateTime currentTime = DateTime.now(); // Get the current time

      final Duration difference = currentTime.difference(storedTime); // Calculate time difference
      final int timeDifferenceInMinutes = difference.inMinutes; // Convert difference to minutes

      final int adjustedTimeRemaining = row[1] - timeDifferenceInMinutes; // Adjusted timeRemaining

      final student = DisplayStudent(
        firstname: row[0],
        timeRemaining: adjustedTimeRemaining,
        status: row[2],
        subject: row[3],
        updateCount: updateCounts,
        mathStudents: mathStudents,
        readStudents: readStudents,
        totalTime: row[5],
      );

      if (student.subject == 'Math') {
        mathStudents.add(student);
        updateCounts(student.countdownBar.status, student.subject);
      } else if (student.subject == 'Read') {
        readStudents.add(student);
        updateCounts(student.countdownBar.status, student.subject);
      }
    }
  }

  // Future<void> restoreDataFromCsv() async {
  //   final csvData = await CsvHelper.readCsv('data.csv');
  //   for (final row in csvData) {
  //     final student = DisplayStudent(
  //       firstname: row[0],
  //       timeRemaining: row[1],
  //       status: row[2],
  //       subject: row[3],
  //       updateCount: updateCounts,
  //       mathStudents: mathStudents,
  //       readStudents: readStudents,
  //     );
  //     if (student.subject == 'Math') {
  //       mathStudents.add(student);
  //       updateCounts(student.countdownBar.status, student.subject);
  //
  //     } else if (student.subject == 'Read') {
  //       readStudents.add(student);
  //       updateCounts(student.countdownBar.status, student.subject);
  //     }
  //   }
  // }

  Future<void> removeStudentFromCsv(String name, String subject) async {
    // Remove student from mathStudents or readStudents list based on the subject

    if(subject == 'Math'){

      mathStudents = List.from(mathStudents); // Create a copy of the list

      for(final student in mathStudents){

           if(student.firstname == name){
             mathStudents.remove(student);
             updateCounts(student.countdownBar.status, student.subject, decrement: true);
             break;
           }

      }

    }
    if(subject == 'Read'){

      readStudents = List.from(readStudents); // Create a copy of the list
      for(final student in readStudents){

        if(student.firstname == name){
          readStudents.remove(student);
          updateCounts(student.countdownBar.status, student.subject, decrement: true);
          break;
        }

      }

    }



    // Create a StudentRecord object to store the removed student's information
    final studentRecord = StudentRecord(
      firstname: name,
      subject: subject,
      scanDateTime: DateTime.now(),
    );

    // Save the student record to student_record.csv
    await saveDataToCsv(filename:'student_record.csv');

    // Save the updated mathStudents and readStudents lists to data.csv
    await saveDataToCsv();

    // Reload the ListView to display the updated list
    setState(() {});
  }

  Future<void> saveDataToCsv({filename = 'data.csv'}) async {
    final List<List<dynamic>> csvData = [];
    final DateTime currentTime = DateTime.now(); // Get the current time

    for (final student in mathStudents + readStudents) {
      csvData.add([
        student.firstname,
        student.countdownBar.secondsRemaining,
        student.countdownBar.status,
        student.subject,
        currentTime, // Add the current time to the CSV data
        student.countdownBar.totalTime,
      ]);
    }

    await CsvHelper.writeCsv(csvData, filename);
  }


  // Future<void> saveDataToCsv({filename = 'data.csv'}) async {
  //   final List<List<dynamic>> csvData = [];
  //   for (final student in mathStudents + readStudents) {
  //     csvData.add([
  //       student.firstname,
  //       student.countdownBar.secondsRemaining,
  //       student.countdownBar.status,
  //       student.subject,
  //     ]);
  //   }
  //   await CsvHelper.writeCsv(csvData,filename);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ColorBox(color: Colors.green, count: greenCountM),
                    ColorBox(color: Colors.yellow, count: yellowCountM),
                    ColorBox(color: Colors.red, count: redCountM),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ColorBox(color: Colors.green, count: greenCountR),
                    ColorBox(color: Colors.yellow, count: yellowCountR),
                    ColorBox(color: Colors.red, count: redCountR),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ),
                  );
                  setState(() {
                    if (res is String) {
                      result = res;
                      if (studentNames.document(result) != null) {
                        studentNames.document(result).get().then((recordlist) async {
                          if (recordlist['isMath']) {
                            final int timeRemaining = await getTimeRemianing(result);
                            final student = DisplayStudent(

                              firstname: recordlist['FirstName'],
                              timeRemaining: timeRemaining,
                              status: 'Green',
                              subject: 'Math',
                              updateCount: updateCounts,
                              mathStudents: mathStudents,
                              readStudents: readStudents,
                              totalTime: timeRemaining,

                            );

                            setState(() {
                              mathStudents.add(student);
                              greenCountM++;
                              DateTime _time = DateTime.now();
                              String currentTime = DateFormat("yyyy/MM/dd HH:mm:ss").format(_time);
                              DateTime endTime = _time.add(new Duration(hours: 2));
                              String endTimeFormatted = DateFormat("yyyy/MM/dd HH:mm:ss").format(endTime);
                              _saveAttendanceToFirestore(result, currentTime, endTimeFormatted);

                            });
                          }

                          if (recordlist['isReading']) {

                            final int timeRemaining = await getTimeRemianing(result);
                            final student = DisplayStudent(
                              firstname: recordlist['FirstName'],
                              timeRemaining: timeRemaining ,
                              status: 'Green',
                              subject: 'Read',
                              updateCount: updateCounts,
                              mathStudents: mathStudents,
                              readStudents: readStudents,
                              totalTime: timeRemaining,
                            );

                            setState(() {
                              readStudents.add(student);
                              greenCountR++;
                              DateTime _time = DateTime.now();
                              String currentTime = DateFormat("yyyy/MM/dd HH:mm:ss").format(_time);
                              DateTime endTime = _time.add(new Duration(hours: 2));
                              String endTimeFormatted = DateFormat("yyyy/MM/dd HH:mm:ss").format(endTime);
                              _saveAttendanceToFirestore(result, currentTime, endTimeFormatted);
                            });
                          }
                        }).catchError((e) {
                          // Handle any errors that occurred during the async operations
                        });
                      }
                    }
                  });
                },
                icon: Icon(Icons.qr_code),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        'Math Students',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          itemCount: mathStudents.length,
                          itemBuilder: (context, index) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Remove Student'),
                                        content: Text(
                                            'Are you sure you want to remove ${mathStudents[index].firstname}?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Remove'),
                                            onPressed: () {

                                              setState(() {
                                                removeStudentFromCsv(mathStudents[index].firstname,mathStudents[index].subject);
                                                Navigator.of(context).pop();
                                              });


                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: ListTile(
                                  title: Text(mathStudents[index].firstname),
                                  subtitle: mathStudents[index].countdownBar,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 4.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        'Read Students',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          itemCount: readStudents.length,
                          itemBuilder: (context, index) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Remove Student'),
                                        content: Text(
                                            'Are you sure you want to remove ${readStudents[index].firstname}?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Remove'),
                                            onPressed: () {
                                              setState(() {
                                                removeStudentFromCsv(readStudents[index].firstname,readStudents[index].subject);
                                                Navigator.of(context).pop();
                                              });

                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: ListTile(
                                  title: Text(readStudents[index].firstname),
                                  subtitle: readStudents[index].countdownBar,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 4.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateCounts(String status, String subject, {bool decrement = false}) {
    setState(() {
      if (subject == 'Math') {
        if (status == 'Green') {
          greenCountM += decrement ? -1 : 1;
        } else if (status == 'Yellow') {
          greenCountM += decrement ? 1 : -1;
          yellowCountM += decrement ? -1 : 1;
        } else if (status == 'Red') {
          yellowCountM += decrement ? 1 : -1;
          redCountM += decrement ? -1 : 1;
        }
      } else if (subject == 'Read') {
        if (status == 'Green') {
          greenCountR += decrement ? -1 : 1;
        } else if (status == 'Yellow') {
          greenCountR += decrement ? 1 : -1;
          yellowCountR += decrement ? -1 : 1;
        } else if (status == 'Red') {
          yellowCountR += decrement ? 1 : -1;
          redCountR += decrement ? -1 : 1;
        }
      }
    });
  }

  Future<int> getTimeRemianing(String id) async {

    final firestore = Firestore.instance;
    final regularDetailsCollection = firestore.collection('Students').document(id).collection("Regular Schedule");
    int time;
    print("came here");

    try {
      final studentlist = await regularDetailsCollection.get();

      print(studentlist);
      for (final data in studentlist) {



          time = int.parse(data['duration']) ;
          print(time);
          return time;


      }

    } catch (e) {
      print(e.toString());
    }

    return 45;

  }


// void updateCounts(String status, String subject) {
  //   setState(() {
  //     if (subject == 'Math') {
  //       if (status == 'Green') {
  //         greenCountM++;
  //       } else if (status == 'Yellow') {
  //         greenCountM--;
  //         yellowCountM++;
  //       } else if (status == 'Red') {
  //         yellowCountM--;
  //         redCountM++;
  //       }
  //     } else if (subject == 'Read') {
  //       if (status == 'Green') {
  //         greenCountR++;
  //       } else if (status == 'Yellow') {
  //         greenCountR--;
  //         yellowCountR++;
  //       } else if (status == 'Red') {
  //         yellowCountR--;
  //         redCountR++;
  //       }
  //     }
  //   });
  // }
}

class DisplayStudent {
  String firstname;
  CountdownBar countdownBar;
  Function(String, String) updateCount;
  String subject;
  List<DisplayStudent> mathStudents;
  List<DisplayStudent> readStudents;


  DisplayStudent({
    required this.firstname,
    required int timeRemaining,
    required String status,
    required this.subject,
    required this.updateCount,
    required this.mathStudents,
    required this.readStudents,
    required int totalTime,

  }) : countdownBar = CountdownBar(
    timeRemaining: timeRemaining,
    status: status,
    updateCount: updateCount,
    subject: subject,
    name: firstname,
    mathStudents: [],
    readStudents: [],
    totalTime: totalTime,
  );


}

class CountdownBar extends StatefulWidget {
  final int timeRemaining;
  final String status;
  final String subject;
  final String name;
  int totalTime;
  late int secondsRemaining;
  late List<DisplayStudent> mathStudents;
  late List<DisplayStudent> readStudents;
  final void Function(String, String) updateCount;


  CountdownBar({
    Key? key,
    required this.timeRemaining,
    required this.status,
    required this.updateCount,
    required this.subject,
    required this.totalTime,
    required this.name, required this.mathStudents, required this.readStudents,
  }) : super(key: key) {
    secondsRemaining = timeRemaining;
  }


  @override
  State<CountdownBar> createState() => _CountdownBarState();


}

class _CountdownBarState extends State<CountdownBar> {
  double progress = 1.0;

  late String statusColor;
  Color barColor = Colors.green;



  @override
  void initState() {
    super.initState();
    widget.secondsRemaining = widget.timeRemaining;
    statusColor = widget.status;
    startTimer();
  }

  late Timer timer;

  void startTimer() {
    const oneMin = Duration(minutes: 1);
    timer = Timer.periodic(oneMin, (Timer timer) {

      setState(() {
               if (widget.secondsRemaining > 0) {
                 widget.secondsRemaining--;

                if (widget.secondsRemaining <= 30 && widget.secondsRemaining > 15) {
                  if (statusColor != 'Yellow') {
                    widget.updateCount('Yellow', widget.subject);
                    statusColor = 'Yellow';
                  }
                  barColor = Colors.yellow;
                } else if (widget.secondsRemaining <= 15 && widget.secondsRemaining > 0) {
                  if (statusColor != 'Red') {
                    widget.updateCount('Red', widget.subject);
                    statusColor = 'Red';
                  }
                  barColor = Colors.red;
                }
                progress = widget.secondsRemaining / widget.totalTime;
              } else {
                timer.cancel();
              }
      });
    });
  }


  void deleteStudent() {
    setState(() {
      if (widget.subject == 'Math') {

        widget.mathStudents.removeWhere((student) => student.firstname == widget.name);


        //updateCounts(widget.status, widget.subject);
      } else if (widget.subject == 'Read') {

        widget.readStudents.removeWhere((student) => student.firstname == widget.name);
        //updateCounts(widget.status, widget.subject);

      }
    });
  }

  void saveRecordToCsv(StudentRecord studentRecord) async {
    final csvData = [
      [studentRecord.firstname, studentRecord.subject, studentRecord.scanDateTime.toString()]
    ];
    await CsvHelper.writeCsv(csvData, 'student_records.csv');
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Time Remaining: ${widget.secondsRemaining} minutes',
          // Display the decreasing time
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
          backgroundColor: Colors.grey[300],
          minHeight: 10, // Increase the thickness of the bar
        ),
      ],
    );
  }




}

class ColorBox extends StatelessWidget {
  final Color color;
  final int count;

  const ColorBox({
    Key? key,
    required this.color,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 30,
      color: color,
      child: Center(
        child: Text(
          count.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class CsvHelper {

  static Future<List<List<dynamic>>> readCsv(String s) async {
    final file = File(s);
    if (await file.exists()) {
      final csvContent = await file.readAsString();
      return CsvToListConverter().convert(csvContent);
    }
    return [];
  }

  static Future<void> writeCsv(List<List<dynamic>> csvData, String s) async {
    final file = File(s);
    final csvContent = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvContent);
  }
}


class StudentRecord {
  String firstname;
  String subject;
  DateTime scanDateTime;

  StudentRecord({
    required this.firstname,
    required this.subject,
    required this.scanDateTime,
  });
}
