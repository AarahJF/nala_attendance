import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firedart/firedart.dart';
import 'package:nala_attendance/Data_Structures/student_detail.dart';
import 'package:nala_attendance/student.dart';
import 'package:nala_attendance/student_profile.dart';

import 'Data_Structures/student_schedule.dart';
import 'Utility/csv_helper.dart';

class MaintainStudentProfile extends StatefulWidget {
  final List<StudSchedule> studSchedule;
  MaintainStudentProfile({
    required this.studSchedule,
  });

  @override
  State<MaintainStudentProfile> createState() => _MaintainStudentProfileState();
}

class _MaintainStudentProfileState extends State<MaintainStudentProfile> {
  List<Student> students = [];
  List<StudentDetail> dataDetail = [];
  List<Student> modifiedStudents = []; // Track modified students
  bool showInactiveStudents = false;
  bool showActiveStudents = false;

  final CollectionReference studentsRef =
      Firestore.instance.collection("Students");

  Future<void> deleteStudent(String id) async {
    try {
      await studentsRef.document(id).delete();
      print('Student with ID ${id} deleted.');
      //getStudents(); // Refresh the student list after deletion
      getStudentDetailFromCSV();
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  Future<void> getStudentDetailFromCSV() async {
    final csvData = await CsvHelper.readCsv('student_detail.csv');
    for (final row in csvData) {
      if (row[3].toString().toLowerCase().trim() == "firstname" ||
          (row[3] == "" && row[4] == "")) {
        continue;
      }

      dataDetail.add(StudentDetail(
        studentID: row[0]?.toString() ?? "",
        studentIDOld: row[1]?.toString() ?? "",
        lastName: row[2]?.toString() ?? "",
        firstName: row[3]?.toString() ?? "",
        dateOfBirth: row[4]?.toString() ?? "",
        gradeLevel: row[5]?.toString() ?? "",
        gender: row[6]?.toString() ?? "",
        email: row[7]?.toString() ?? "",
        kumonPoints: row[8]?.toString() ?? "",
        schoolName: row[9]?.toString() ?? "",
        address1: row[10]?.toString() ?? "",
        address2: row[11]?.toString() ?? "",
        address3: row[12]?.toString() ?? "",
        city: row[13]?.toString() ?? "",
        stateCode: row[14]?.toString() ?? "",
        zipCode: row[15]?.toString() ?? "",
        phoneNumber: row[16]?.toString() ?? "",
        surveyHowType: row[17]?.toString() ?? "",
        originHowSource: row[18]?.toString() ?? "",
        surveyWhyType: row[19]?.toString() ?? "",
        originWhySource: row[20]?.toString() ?? "",
        motherLastName: row[21]?.toString() ?? "",
        motherFirstName: row[22]?.toString() ?? "",
        motherEmail: row[23]?.toString() ?? "",
        motherAddress1: row[24]?.toString() ?? "",
        motherAddress2: row[25]?.toString() ?? "",
        motherAddress3: row[26]?.toString() ?? "",
        motherCity: row[27]?.toString() ?? "",
        motherStateCode: row[28]?.toString() ?? "",
        motherZipCode: row[29]?.toString() ?? "",
        motherHPPhone: row[30]?.toString() ?? "",
        motherBPPhone: row[31]?.toString() ?? "",
        motherCPPhone: row[32]?.toString() ?? "",
        motherFNPhone: row[33]?.toString() ?? "",
        motherPNPhone: row[34]?.toString() ?? "",
        fatherLastName: row[35]?.toString() ?? "",
        fatherFirstName: row[36]?.toString() ?? "",
        fatherEmail: row[37]?.toString() ?? "",
        fatherAddress1: row[38]?.toString() ?? "",
        fatherAddress2: row[39]?.toString() ?? "",
        fatherAddress3: row[40]?.toString() ?? "",
        fatherCity: row[41]?.toString() ?? "",
        fatherStateCode: row[42]?.toString() ?? "",
        fatherZipCode: row[43]?.toString() ?? "",
        fatherHPPhone: row[44]?.toString() ?? "",
        fatherBPPhone: row[45]?.toString() ?? "",
        fatherCPPhone: row[46]?.toString() ?? "",
        fatherFNPhone: row[47]?.toString() ?? "",
        fatherPNPhone: row[48]?.toString() ?? "",
        guardianLastName: row[49]?.toString() ?? "",
        guardianFirstName: row[50]?.toString() ?? "",
        guardianEmail: row[51]?.toString() ?? "",
        guardianAddress1: row[52]?.toString() ?? "",
        guardianAddress2: row[53]?.toString() ?? "",
        guardianAddress3: row[54]?.toString() ?? "",
        guardianCity: row[55]?.toString() ?? "",
        guardianStateCode: row[56]?.toString() ?? "",
        guardianZipCode: row[57]?.toString() ?? "",
        guardianHPPhone: row[58]?.toString() ?? "",
        guardianBPPhone: row[59]?.toString() ?? "",
        guardianCPPhone: row[60]?.toString() ?? "",
        guardianFNPhone: row[61]?.toString() ?? "",
        guardianPNPhone: row[62]?.toString() ?? "",
        otherLastName: row[63]?.toString() ?? "",
        otherFirstName: row[64]?.toString() ?? "",
        otherEmail: row[65]?.toString() ?? "",
        otherAddress1: row[66]?.toString() ?? "",
        otherAddress2: row[67]?.toString() ?? "",
        otherAddress3: row[68]?.toString() ?? "",
        otherCity: row[69]?.toString() ?? "",
        otherStateCode: row[70]?.toString() ?? "",
        otherZipCode: row[71]?.toString() ?? "",
        otherHPPhone: row[72]?.toString() ?? "",
        otherBPPhone: row[73]?.toString() ?? "",
        otherCPPhone: row[74]?.toString() ?? "",
        otherFNPhone: row[75]?.toString() ?? "",
        otherPNPhone: row[76]?.toString() ?? "",
        subject: row[77]?.toString() ?? "",
        kumonGradeLevelStart: row[78]?.toString() ?? "",
        workSheetLevelStart: row[79]?.toString() ?? "",
        kumonGradeLevel: row[80]?.toString() ?? "",
        enrollDate: row[81]?.toString() ?? "",
        st1: row[82]?.toString() ?? "",
        st2: row[83]?.toString() ?? "",
        centerDays: row[84]?.toString() ?? "",
        enrollEndDate: row[85]?.toString() ?? "",
        partialExemptEndDate: row[86]?.toString() ?? "",
        customFilter: row[87]?.toString() ?? "",
      ));
    }
  }

  void getStudentsFromExcelData() async {
    List<Student> studentList = [];

    try {
      final studentlist = await studentsRef.get();

      for (final data in dataDetail) {
        final student = Student(
          firstName: data.firstName,
          lastName: data.lastName,
          studentId: data.studentID,
          TCAID: '',
          isActive: data.firstName != null && !data.firstName.isEmpty,
          isDoingMath: data.subject == "math",
          isReading: data.subject == "read",
          mathLocation: '',
          readingLocation: '',
        );

        studentList.add(student);
      }
      // for (final data in studentlist) {
      //   final student = Student(
      //     firstName: data['FirstName'],
      //     lastName: data['LastName'],
      //     studentId: data['CMSStudentID'],
      //     isReading: data['isReading'],
      //     isDoingMath: data['isMath'],
      //     isActive: data['isActive'],
      //     mathLocation: data['mathLocation'],
      //     readingLocation: data['readingLocation'],
      //     TCAID: data['TCAStudentID'],
      //   );

      //   studentList.add(student);
      // }
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

  // void getStudents() async {
  //   List<Student> studentList = [];

  //   try {
  //     final studentlist = await studentsRef.get();

  //     for (final data in studentlist) {
  //       final student = Student(
  //         firstName: data['FirstName'],
  //         lastName: data['LastName'],
  //         studentId: data['CMSStudentID'],
  //         isReading: data['isReading'],
  //         isDoingMath: data['isMath'],
  //         isActive: data['isActive'],
  //         mathLocation: data['mathLocation'],
  //         readingLocation: data['readingLocation'],
  //         TCAID: data['TCAStudentID'],
  //       );

  //       studentList.add(student);
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }

  //   if (mounted) {
  //     setState(() {
  //       students = studentList;
  //       modifiedStudents = List.from(
  //           studentList); // Initialize modified students with original data
  //     });
  //   }

  //   // setState(() {
  //   //   students = studentList;
  //   //   modifiedStudents = List.from(studentList); // Initialize modified students with original data
  //   // });
  // }

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

    //getStudents();
    getStudentDetailFromCSV();
    getStudentsFromExcelData();
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
                  getStudentDetailFromCSV();
                  getStudentsFromExcelData();
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
                                          studSchedule: widget.studSchedule,
                                          dataDetails: dataDetail,
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
