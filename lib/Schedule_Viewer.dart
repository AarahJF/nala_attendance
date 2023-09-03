import 'package:file_picker/file_picker.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:nala_attendance/schedule.dart';
import 'package:nala_attendance/week_picker.dart';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'dart:io';
import 'package:intl/intl.dart'; // Import the intl library
import 'package:pdf/widgets.dart' show PdfColor;

import 'Data_Structures/student_schedule.dart';

class StudentCell {
  final String name;
  final String subject;

  StudentCell({
    required this.name,
    required this.subject,
  });
}

class Student {
  final String name;
  final String subject;
  final String location;
  final String startTime;

  Student({
    required this.startTime,
    required this.location,
    required this.name,
    required this.subject,
  });
}

List<String> dayOptions = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class ScheduleViewPage extends StatefulWidget {
  final List<StudSchedule> studSchedule;

  ScheduleViewPage({required this.studSchedule});

  @override
  State<ScheduleViewPage> createState() => _ScheduleViewPageState();
}

class _ScheduleViewPageState extends State<ScheduleViewPage> {
  String selectedDay = '';
  String selectedWeek =
      ''; // Global variable to store the selected week details

  List<Student> students = []; // List to store Regular Schedule

  String getFormattedCurrentWeek() {
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    DateTime sunday = monday.add(Duration(days: 6));

    String formattedMonday = DateFormat('yyyy / MM / dd').format(monday);
    String formattedSunday = DateFormat('yyyy / MM / dd').format(sunday);

    return "$formattedMonday - $formattedSunday";
  }

  void getStudents() {
    try {
      students.clear(); // Clear the previous schedule data
      for (final data in widget.studSchedule) {
        if (data.week == selectedWeek && data.day == selectedDay) {
          final student = Student(
            startTime: data.startTime,
            location: data.location,
            name: data.name,
            subject: data.subject,
          );
          students.add(student);
        }
      }
    } catch (e) {
      //print(e.toString());
    }
  }

  final List<String> locations = [
    'Primary Instruction',
    'Primary II',
    'Early Learners',
    'Early Learners 1st',
    'Transition/Reserved',
    'Transition/Reserved2',
  ];

  final List<String> times = [
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
    '5:30 PM',
    '6:00 PM',
    '6:30 PM'
  ];

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pdfWidgets.Document();

    final cellStyle = pdfWidgets.TextStyle();

    // Define the title
    final title = pdfWidgets.Header(
      level: 0,
      child: pdfWidgets.Container(
        alignment: pdfWidgets.Alignment.center,
        child: pdfWidgets.Text(
          'Week - $selectedWeek   Day - $selectedDay',
        ),
      ),
    );

    // Add content to the PDF
    pdf.addPage(
      pdfWidgets.MultiPage(
        margin: const pdfWidgets.EdgeInsets.all(16),
        build: (context) => [
          // Add the title
          title,

          // Create a table with headers
          pdfWidgets.Table.fromTextArray(
            border: pdfWidgets.TableBorder.all(
              color: PdfColor.fromInt(0xFF0000FF), // Blue color
              width: 1,
            ),

            data: _getTableDataForPdf(), // Use the updated tableData here

            cellStyle: cellStyle,
          ),
        ],
      ),
    );

    // Show a dialog to get the folder location and file name
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    String? fileName = await _showSaveDialog(context);

    if (folderPath != null && fileName != null) {
      final pdfPath = '$folderPath/$fileName.pdf';

      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $pdfPath')),
      );
    }
  }

  List<String> _getTableHeaders() {
    // Define table headers
    List<String> headers = ['Location', ...times];

    return headers;
  }

  List<List<String?>> _getTableDataForPdf() {
    // Create a 2D list to store table data
    List<List<String?>> tableData = [];

    // Add header row (times)
    List<String?> headerRow = ['Location', ...times];
    tableData.add(headerRow);

    // Add data rows
    for (int i = 0; i < locations.length; i++) {
      List<String?> row = [];
      row.add(locations[i]);

      for (int j = 0; j < times.length; j++) {
        String? cellData = ''; // Initialize as empty string
        final List<StudentCell> studentsAtCell = [];

        // Iterate through the StudSchedule objects for this location and time
        for (Student schedule in students) {
          if (schedule.location == locations[i] &&
              schedule.startTime == times[j]) {
            studentsAtCell.add(
              StudentCell(name: schedule.name, subject: schedule.subject),
            );
          }
        }

        // Build a string containing student names and subjects
        if (studentsAtCell.isNotEmpty) {
          cellData = studentsAtCell
              .map((student) => '${student.name} (${student.subject})')
              .join('\n');
        }

        row.add(cellData);
      }

      tableData.add(row);
    }

    return tableData;
  }

  List<List<String>> _getTableData() {
    // Create a 2D list to store table data
    List<List<String>> tableData = [];

    // Add data rows
    for (int i = 0; i < locations.length; i++) {
      List<String> row = [];
      for (int j = 0; j < times.length; j++) {
        String cellData = '';
        final List<StudentCell> studentsAtCell = [];

        // Iterate through the StudSchedule objects for this location and time
        for (Student schedule in students) {
          if (schedule.location == locations[i] &&
              schedule.startTime == times[j]) {
            studentsAtCell.add(
                StudentCell(name: schedule.name, subject: schedule.subject));
          }
        }

        cellData = '(${studentsAtCell.length})\n';
        for (StudentCell student in studentsAtCell) {
          cellData += '${student.name} (${student.subject})\n';
        }

        row.add(cellData);
      }
      tableData.add(row);
    }

    return tableData;
  }

  Future<String?> _showSaveDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter file name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: selectedWeek + ' ' + selectedDay,
                  hintText: selectedWeek + ' ' + selectedDay,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getCurrentDay() {
    DateTime now = DateTime.now();
    return DateFormat('EEEE')
        .format(now); // Format the current date to get the day
  }

  @override
  void initState() {
    // TODO: implement initState
    selectedDay = _getCurrentDay();
    selectedWeek = getFormattedCurrentWeek();
    getStudents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Icon(Icons.menu), // You can replace this with your own menu icon
            // SizedBox(width: 8), // Adding some spacing between icon and title
            Text('Schedule View'),
          ],
        ),
        actions: [
          Row(
            children: [
              WeekDropDown(
                onChanged: (String newValue) {
                  setState(() {
                    selectedWeek = newValue;
                    getStudents();
                  });
                },
                backColor: Colors.white,
              ),
              SizedBox(
                width: 300,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background color to white
                  borderRadius:
                      BorderRadius.circular(10.0), // Set the border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      focusColor: Colors.blue,
                      value: selectedDay,
                      items: dayOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDay = newValue!;
                          getStudents();
                        });
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(width: 20), // Adding some spacing between icon and title
              IconButton(
                icon: Icon(Icons.print),
                onPressed: () async {
                  await _generatePdf(
                      context); // Call the function to generate PDF here
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Table(
              defaultColumnWidth: IntrinsicColumnWidth(),
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(child: SizedBox(width: 100)),
                    for (String time in times)
                      TableCell(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          color: Colors.blue,
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                for (int i = 0; i < locations.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          color: Colors.blue,
                          child: Text(
                            locations[i],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      for (int j = 0; j < times.length; j++)
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getTableData()[i]
                                    [j]), // Use the updated tableData here
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
