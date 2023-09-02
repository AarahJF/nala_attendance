import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firedart/firedart.dart';
import 'package:nala_attendance/student.dart';
import 'package:nala_attendance/student_profile.dart';

class MaintainStudentProfile extends StatefulWidget {
  const MaintainStudentProfile({Key? key}) : super(key: key);

  @override
  State<MaintainStudentProfile> createState() => _MaintainStudentProfileState();
}

class _MaintainStudentProfileState extends State<MaintainStudentProfile> {
  List<Student> students = [];
  List<Student> modifiedStudents = []; // Track modified students
  bool showInactiveStudents = false;
  bool showActiveStudents = false;

  final CollectionReference studentsRef =
      Firestore.instance.collection("Students");

  Future<void> deleteStudent(String id) async {
    try {
      await studentsRef.document(id).delete();
      print('Student with ID ${id} deleted.');
      getStudents(); // Refresh the student list after deletion
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  void getStudents() async {
    List<Student> studentList = [];

    try {
      final studentlist = await studentsRef.get();

      for (final data in studentlist) {
        final student = Student(
          firstName: data['FirstName'],
          lastName: data['LastName'],
          studentId: data['CMSStudentID'],
          isReading: data['isReading'],
          isDoingMath: data['isMath'],
          isActive: data['isActive'],
          mathLocation: data['mathLocation'],
          readingLocation: data['readingLocation'],
          TCAID: data['TCAStudentID'],
        );

        studentList.add(student);
      }
    } catch (e) {
      print(e.toString());
    }

    if (mounted) {
      setState(() {
        students = studentList;
        modifiedStudents = List.from(
            studentList); // Initialize modified students with original data
      });
    }

    // setState(() {
    //   students = studentList;
    //   modifiedStudents = List.from(studentList); // Initialize modified students with original data
    // });
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    if ([
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform)) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.grey[50],
      statusBarColor: Colors.grey[50],
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));

    getStudents();
    super.initState();
  }

  Widget build(BuildContext context) {
    List<Student> filteredStudents = [];

    if (showInactiveStudents && showActiveStudents) {
      filteredStudents = modifiedStudents;
    } else if (showInactiveStudents) {
      filteredStudents =
          modifiedStudents.where((student) => !student.isActive).toList();
    } else if (showActiveStudents) {
      filteredStudents =
          modifiedStudents.where((student) => student.isActive).toList();
    } else {
      filteredStudents = modifiedStudents;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TCA - The Center Administrator',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Student Details'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Reset button functionality
                setState(() {
                  modifiedStudents = List.from(
                      students); // Restore modified students from original data
                  getStudents();
                });
              },
              child: Text('Reset'),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                    ),
                    children: [
                      Text(
                        'First Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Last Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Student ID',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Reading',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mathes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Delete',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView(
                children: [
                  Table(
                    children: [
                      for (var index = 0;
                          index < filteredStudents.length;
                          index++)
                        TableRow(
                          decoration: BoxDecoration(
                            color: filteredStudents[index].isActive
                                ? null
                                : Colors.grey[300],
                          ),
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    useSafeArea: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SizedBox(
                                        width: 7000,
                                        height: 7000,
                                        child: StudentDetailsPopup(
                                          student: filteredStudents[index],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      filteredStudents[index].firstName,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(filteredStudents[index].lastName),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(filteredStudents[index].studentId),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Checkbox(
                                value: filteredStudents[index].isReading,
                                onChanged: (value) {
                                  setState(() {
                                    filteredStudents[index].isReading =
                                        value ?? false;
                                  });
                                },
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Checkbox(
                                value: filteredStudents[index].isDoingMath,
                                onChanged: (value) {
                                  setState(() {
                                    filteredStudents[index].isDoingMath =
                                        value ?? false;
                                  });
                                },
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: filteredStudents[index].isActive
                                    ? Icon(Icons.check, color: Colors.green)
                                    : Icon(Icons.close, color: Colors.red),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text(
                                          'Are you sure you want to delete student with ID: ${filteredStudents[index].studentId}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await deleteStudent(
                                                filteredStudents[index]
                                                    .studentId);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 150),
                                child: Icon(Icons.delete, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: showInactiveStudents,
                  onChanged: (value) {
                    setState(() {
                      showInactiveStudents = value ?? false;
                    });
                  },
                ),
                Text('Show Inactive Students'),
                Checkbox(
                  value: showActiveStudents,
                  onChanged: (value) {
                    setState(() {
                      showActiveStudents = value ?? false;
                    });
                  },
                ),
                Text('Show Active Students'),
              ],
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Save button functionality
                  saveChangesToDatabase(modifiedStudents);
                },
                child: Text('Save Changes'),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  // Close button functionality
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveChangesToDatabase(List<Student> students) async {
    try {
      final List<Map<String, dynamic>> data = students
          .map((student) => {
                'FirstName': student.firstName,
                'LastName': student.lastName,
                'StudentID': student.studentId,
                'isReading': student.isReading,
                'isMath': student.isDoingMath,
                'isActive': student.isActive,
              })
          .toList();

      await studentsRef.add(data as Map<String, dynamic>);
      print('Changes saved to Firestore database.');
    } catch (e) {
      print('Error saving changes: $e');
    }
  }
}
