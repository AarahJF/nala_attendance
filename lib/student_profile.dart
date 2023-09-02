import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nala_attendance/guardian.dart';
import 'package:nala_attendance/student.dart';
import 'package:nala_attendance/tab_view.dart';

class StudentDetailsPopup extends StatefulWidget {
  final Student student;

  const StudentDetailsPopup({required this.student});

  @override
  State<StudentDetailsPopup> createState() => _StudentDetailsPopupState();
}

class _StudentDetailsPopupState extends State<StudentDetailsPopup> {
  List<Guardian> guardians = [];
  //final CollectionReference studentsRef = Firestore.instance.collection('Guardians');

  String firstName = '';
  String lastName = '';
  String CMSstudentId = '';
  String TCAstudentId = '';
  bool isActive = false;
  String readingValue = ''; // Updated to null
  String mathValue = ''; // Updated to null
  String? momFirstName;
  String? momLastName;
  String? momEmail;
  String? momPhone;
  String? dadFirstName;
  String? dadLastName;
  String? dadEmail;
  String? dadPhone;

  void getStudents(String cmsStudentId) async {
    final firestore = Firestore.instance;
    final guardianDetailsCollection = firestore
        .collection('Students')
        .document(cmsStudentId)
        .collection("Guardian");

    try {
      final studentlist = await guardianDetailsCollection.get();

      for (final data in studentlist) {
        setState(() {
          final guardian = Guardian(
            relation: data['relationType'],
            firstName: data['firstName'],
            lastName: data['lastName'],
            email: data['email'],
            phone: data['phoneNumber'],
          );

          setState(() {
            guardians.add(guardian);
          });

          //print(guardians);
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getStudents(widget.student.studentId);
    super.initState();
    if (widget.student.mathLocation != null) {
      mathValue = widget.student.mathLocation;
    }
    if (widget.student.readingLocation != null) {
      readingValue = widget.student.readingLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerWidth =
        screenSize.width; // Set the desired fraction of the screen width
    final containerHeight =
        screenSize.height; // Set the desired fraction of the screen height

    return AlertDialog(
      title: Text('Student Profiles'),
      content: Container(
        height: containerHeight,
        width: containerWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: containerHeight * 0.69,
              color: Colors.blue,
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Name:',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${widget.student.firstName} ${widget.student.lastName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Text(
                            'CMS Student ID:',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.student.studentId,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Text(
                            'TCA Student ID:',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.student.TCAID,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Reading: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                      ),
                      Checkbox(
                        value: widget.student.isReading,
                        onChanged: (value) {
                          setState(() {
                            widget.student.isReading = value ?? false;
                          });
                        },
                      ),
                      SizedBox(
                        width: 28,
                      ),
                      Text(
                        'Mathes: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                      ),
                      Checkbox(
                        value: widget.student.isDoingMath,
                        onChanged: (value) {
                          setState(() {
                            widget.student.isDoingMath = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  Container(
                    height: containerHeight * 0.165,
                    child: Row(
                      children: [
                        if (widget.student.isReading)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Main Room',
                                    style: TextStyle(),
                                  ),
                                  Radio<String>(
                                    value: 'Main Room',
                                    groupValue: readingValue,
                                    onChanged: (value) {
                                      setState(() {
                                        readingValue = value!;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.white;
                                      }
                                      return Colors.black;
                                    }),
                                    visualDensity:
                                        VisualDensity.adaptivePlatformDensity,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Early Learner',
                                    style: TextStyle(),
                                  ),
                                  Radio<String>(
                                    value: 'Early Learner',
                                    groupValue: readingValue,
                                    onChanged: (value) {
                                      setState(() {
                                        readingValue = value!;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.white;
                                      }
                                      return Colors.black;
                                    }),
                                    visualDensity:
                                        VisualDensity.adaptivePlatformDensity,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Primary Instruction',
                                  ),
                                  Radio<String>(
                                    value: 'Primary Instruction',
                                    groupValue: readingValue,
                                    onChanged: (value) {
                                      setState(() {
                                        readingValue = value!;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.white;
                                      }
                                      return Colors.black;
                                    }),
                                    visualDensity:
                                        VisualDensity.adaptivePlatformDensity,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (widget.student.isDoingMath)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Main Room',
                                  ),
                                  Radio<String>(
                                    value: 'Main Room',
                                    groupValue: mathValue,
                                    onChanged: (value) {
                                      mathValue = value!;
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    activeColor: Colors.white,
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.white;
                                      }
                                      return Colors.black;
                                    }),
                                    visualDensity:
                                        VisualDensity.adaptivePlatformDensity,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Early Learner',
                                  ),
                                  Radio<String>(
                                    value: 'Early Learner',
                                    groupValue: mathValue,
                                    onChanged: (value) {
                                      mathValue = value!;
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    activeColor: Colors.white,
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    fillColor: MaterialStateProperty.all<Color>(
                                        Colors.black),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Primary Instruction',
                                  ),
                                  Radio<String>(
                                    value: 'Primary Instruction',
                                    groupValue: mathValue,
                                    onChanged: (value) {
                                      mathValue = value!;
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    activeColor: Colors.white,
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    fillColor: MaterialStateProperty.all<Color>(
                                        Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    width: double.infinity,
                    height: containerHeight * 0.4,
                    child: Column(
                      children: [
                        Expanded(
                          // Wrap TabbedContainer with Expanded
                          child: TabbedContainer(
                              guardians,
                              widget.student.isReading,
                              widget.student.isDoingMath,
                              widget.student.studentId,
                              '${widget.student.firstName}' +
                                  " " +
                                  '${widget.student.lastName}'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
