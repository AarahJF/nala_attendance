import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as dt;
import 'package:intl/intl.dart';
import 'package:qr_image_generator/qr_image_generator.dart';

import 'Data_Structures/student_detail.dart';
import 'Utility/csv_helper.dart';
import 'guardian.dart';

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _studCMSIDController = TextEditingController();
  final TextEditingController _studTCAIDController = TextEditingController();

  bool _isReading = false;
  bool _isMath = false;
  bool _isActive = false;
  bool firstNameValue = false;
  bool lastNameValue = false;
  bool studCMSIDValue = false;
  bool studTCAIDValue = false;

  List<Guardian> guardianDetails = [];
  List<StudentDetail> studentList = [];

  bool momFirstNameValue = false;
  bool momLastNameValue = false;
  bool momEmailValue = false;
  bool momPhoneValue = false;
  bool dadFirstNameValue = false;
  bool dadLastNameValue = false;
  bool dadEmailValue = false;
  bool dadPhoneValue = false;
  String? readingValue; // Updated to null
  String? mathValue; // Updated to null
  String _data = '';

  Future<void> _pickAndReadExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      print('Selected File: ${file.name}');

      if (file.extension == 'xls' || file.extension == 'xlsx') {
        print('Valid file selected');

        try {
          var bytes = File(file.path!).readAsBytesSync();

          var excel = Excel.decodeBytes(bytes);

          for (var table in excel.tables.keys) {
            print('Table: $table'); // sheet Name
            print('Max Columns: ${excel.tables[table]!.maxColumns}');
            print('Max Rows: ${excel.tables[table]!.maxRows}');

            for (var row in excel.tables[table]!.rows) {
              if (row != null) {
                // Create a Student instance for each row
                StudentDetail student = StudentDetail(
                  studentID: row[0]?.value.toString() ?? '',
                  studentIDOld: row[1]?.value.toString() ?? '',
                  lastName: row[2]?.value.toString() ?? '',
                  firstName: row[3]?.value.toString() ?? '',
                  dateOfBirth: row[4]?.value.toString() ?? '',
                  gradeLevel: row[5]?.value.toString() ?? '',
                  gender: row[6]?.value.toString() ?? '',
                  email: row[7]?.value.toString() ?? '',
                  kumonPoints: row[8]?.value.toString() ?? '',
                  schoolName: row[9]?.value.toString() ?? '',
                  address1: row[10]?.value.toString() ?? '',
                  address2: row[11]?.value.toString() ?? '',
                  address3: row[12]?.value.toString() ?? '',
                  city: row[13]?.value.toString() ?? '',
                  stateCode: row[14]?.value.toString() ?? '',
                  zipCode: row[15]?.value.toString() ?? '',
                  phoneNumber: row[16]?.value.toString() ?? '',
                  surveyHowType: row[17]?.value.toString() ?? '',
                  originHowSource: row[18]?.value.toString() ?? '',
                  surveyWhyType: row[19]?.value.toString() ?? '',
                  originWhySource: row[20]?.value.toString() ?? '',
                  motherLastName: row[21]?.value.toString() ?? '',
                  motherFirstName: row[22]?.value.toString() ?? '',
                  motherEmail: row[23]?.value.toString() ?? '',
                  motherAddress1: row[24]?.value.toString() ?? '',
                  motherAddress2: row[25]?.value.toString() ?? '',
                  motherAddress3: row[26]?.value.toString() ?? '',
                  motherCity: row[27]?.value.toString() ?? '',
                  motherStateCode: row[28]?.value.toString() ?? '',
                  motherZipCode: row[29]?.value.toString() ?? '',
                  motherHPPhone: row[30]?.value.toString() ?? '',
                  motherBPPhone: row[31]?.value.toString() ?? '',
                  motherCPPhone: row[32]?.value.toString() ?? '',
                  motherFNPhone: row[33]?.value.toString() ?? '',
                  motherPNPhone: row[34]?.value.toString() ?? '',
                  fatherLastName: row[35]?.value.toString() ?? '',
                  fatherFirstName: row[36]?.value.toString() ?? '',
                  fatherEmail: row[37]?.value.toString() ?? '',
                  fatherAddress1: row[38]?.value.toString() ?? '',
                  fatherAddress2: row[39]?.value.toString() ?? '',
                  fatherAddress3: row[40]?.value.toString() ?? '',
                  fatherCity: row[41]?.value.toString() ?? '',
                  fatherStateCode: row[42]?.value.toString() ?? '',
                  fatherZipCode: row[43]?.value.toString() ?? '',
                  fatherHPPhone: row[44]?.value.toString() ?? '',
                  fatherBPPhone: row[45]?.value.toString() ?? '',
                  fatherCPPhone: row[46]?.value.toString() ?? '',
                  fatherFNPhone: row[47]?.value.toString() ?? '',
                  fatherPNPhone: row[48]?.value.toString() ?? '',
                  guardianLastName: row[49]?.value.toString() ?? '',
                  guardianFirstName: row[50]?.value.toString() ?? '',
                  guardianEmail: row[51]?.value.toString() ?? '',
                  guardianAddress1: row[52]?.value.toString() ?? '',
                  guardianAddress2: row[53]?.value.toString() ?? '',
                  guardianAddress3: row[54]?.value.toString() ?? '',
                  guardianCity: row[55]?.value.toString() ?? '',
                  guardianStateCode: row[56]?.value.toString() ?? '',
                  guardianZipCode: row[57]?.value.toString() ?? '',
                  guardianHPPhone: row[58]?.value.toString() ?? '',
                  guardianBPPhone: row[59]?.value.toString() ?? '',
                  guardianCPPhone: row[60]?.value.toString() ?? '',
                  guardianFNPhone: row[61]?.value.toString() ?? '',
                  guardianPNPhone: row[62]?.value.toString() ?? '',
                  otherLastName: row[63]?.value.toString() ?? '',
                  otherFirstName: row[64]?.value.toString() ?? '',
                  otherEmail: row[65]?.value.toString() ?? '',
                  otherAddress1: row[66]?.value.toString() ?? '',
                  otherAddress2: row[67]?.value.toString() ?? '',
                  otherAddress3: row[68]?.value.toString() ?? '',
                  otherCity: row[69]?.value.toString() ?? '',
                  otherStateCode: row[70]?.value.toString() ?? '',
                  otherZipCode: row[71]?.value.toString() ?? '',
                  otherHPPhone: row[72]?.value.toString() ?? '',
                  otherBPPhone: row[73]?.value.toString() ?? '',
                  otherCPPhone: row[74]?.value.toString() ?? '',
                  otherFNPhone: row[75]?.value.toString() ?? '',
                  otherPNPhone: row[76]?.value.toString() ?? '',
                  subject: row[77]?.value.toString() ?? '',
                  kumonGradeLevelStart: row[78]?.value.toString() ?? '',
                  workSheetLevelStart: row[79]?.value.toString() ?? '',
                  kumonGradeLevel: row[80]?.value.toString() ?? '',
                  enrollDate: row[81]?.value.toString() ?? '',
                  st1: row[82]?.value.toString() ?? '',
                  st2: row[83]?.value.toString() ?? '',
                  centerDays: row[84]?.value.toString() ?? '',
                  enrollEndDate: row[85]?.value.toString() ?? '',
                  partialExemptEndDate: row[86]?.value.toString() ?? '',
                  customFilter: row[87]?.value.toString() ?? '',
                );

                // Add the Student instance to the list
                studentList.add(student);
              }
            }

            // Print the list of students
            studentList.forEach((student) {
              print(student);
            });
          }
        } catch (e) {
          print('Error decoding Excel file: $e');
        }
      } else {
        // Handle invalid file type or null bytes
        print('Invalid file type or null bytes. Please choose an Excel file.');
      }
    } else {
      // User canceled the file picker
      print('File picking canceled.');
    }

    await saveDataToCsv(filename: 'student_detail.csv');
  }

  Future<void> saveDataToCsv({String filename = 'data.csv'}) async {
    final List<List<dynamic>> csvData = [];
    final DateTime currentTime = DateTime.now(); // Get the current time

    for (final student in studentList) {
      csvData.add([
        student.studentID,
        student.studentIDOld,
        student.lastName,
        student.firstName,
        student.dateOfBirth,
        student.gradeLevel,
        student.gender,
        student.email,
        student.kumonPoints,
        student.schoolName,
        student.address1,
        student.address2,
        student.address3,
        student.city,
        student.stateCode,
        student.zipCode,
        student.phoneNumber,
        student.surveyHowType,
        student.originHowSource,
        student.surveyWhyType,
        student.originWhySource,
        student.motherLastName,
        student.motherFirstName,
        student.motherEmail,
        student.motherAddress1,
        student.motherAddress2,
        student.motherAddress3,
        student.motherCity,
        student.motherStateCode,
        student.motherZipCode,
        student.motherHPPhone,
        student.motherBPPhone,
        student.motherCPPhone,
        student.motherFNPhone,
        student.motherPNPhone,
        student.fatherLastName,
        student.fatherFirstName,
        student.fatherEmail,
        student.fatherAddress1,
        student.fatherAddress2,
        student.fatherAddress3,
        student.fatherCity,
        student.fatherStateCode,
        student.fatherZipCode,
        student.fatherHPPhone,
        student.fatherBPPhone,
        student.fatherCPPhone,
        student.fatherFNPhone,
        student.fatherPNPhone,
        student.guardianLastName,
        student.guardianFirstName,
        student.guardianEmail,
        student.guardianAddress1,
        student.guardianAddress2,
        student.guardianAddress3,
        student.guardianCity,
        student.guardianStateCode,
        student.guardianZipCode,
        student.guardianHPPhone,
        student.guardianBPPhone,
        student.guardianCPPhone,
        student.guardianFNPhone,
        student.guardianPNPhone,
        student.otherLastName,
        student.otherFirstName,
        student.otherEmail,
        student.otherAddress1,
        student.otherAddress2,
        student.otherAddress3,
        student.otherCity,
        student.otherStateCode,
        student.otherZipCode,
        student.otherHPPhone,
        student.otherBPPhone,
        student.otherCPPhone,
        student.otherFNPhone,
        student.otherPNPhone,
        student.subject,
        student.kumonGradeLevelStart,
        student.workSheetLevelStart,
        student.kumonGradeLevel,
        student.enrollDate,
        student.st1,
        student.st2,
        student.centerDays,
        student.enrollEndDate,
        student.partialExemptEndDate,
        student.customFilter,
      ]);
    }

    await CsvHelper.writeCsv(csvData, filename);
  }

  void _generateQRCode() {
    final text = _studCMSIDController.text;
    setState(() {
      _data = text;
    });
  }

  Future<void> _saveQRCode() async {
    if (_data.isEmpty) {
      print('Please generate a QR code first');
      return;
    }

    try {
      // final qrImageData = await QrPainter(
      //   data: _data,
      //   version: QrVersions.auto,
      //   gapless: false,
      // ).toImageData(200.0);

      if (kIsWeb) {
        // Saving images on web is not supported
        throw Exception("Saving images is not supported on web.");
      }

      // final directory = await getDirectory();
      // if (directory != null) {
      //   final fileName = _studCMSIDController.text;
      //   final filePath = path.join(directory.path, fileName);
      //   final file = File(filePath);
      //   await file.writeAsBytes(qrImageData.buffer.asUint8List());
      //   print('QR code saved successfully: $filePath');
      // } else {
      //   throw Exception('Failed to get directory.');
      // }
    } catch (e) {
      print('Failed to save $e');
    }
  }

  Future<Directory?> getDirectory() async {
    if (kIsWeb) {
      // Not supported on web
      return null;
    }

    final result = await FilePicker.platform.getDirectoryPath();
    return result != null ? Directory(result) : null;
  }

  void _addGuardian() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _relationController =
            TextEditingController();
        final TextEditingController _guardianFirstNameController =
            TextEditingController();
        final TextEditingController _guardianLastNameController =
            TextEditingController();
        final TextEditingController _guardianEmailController =
            TextEditingController();
        final TextEditingController _guardianPhoneController =
            TextEditingController();

        return AlertDialog(
          title: Text('Add Guardian Detail'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _relationController,
                  decoration: InputDecoration(labelText: 'Relation Type'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a relation type';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _guardianFirstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _guardianLastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a last name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _guardianEmailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _guardianPhoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    guardianDetails.add(
                      Guardian(
                        relation: _relationController.text,
                        firstName: _guardianFirstNameController.text,
                        lastName: _guardianLastNameController.text,
                        email: _guardianEmailController.text,
                        phone: _guardianPhoneController.text,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _saveGuardiansToFirestore() {
    final firestore = Firestore.instance;
    final guardianDetailsCollection = firestore
        .collection('Students')
        .document(_studCMSIDController.text)
        .collection("Guardian");

    for (var guardian in guardianDetails) {
      guardianDetailsCollection.add({
        'relationType': guardian.relation,
        'firstName': guardian.firstName,
        'lastName': guardian.lastName,
        'email': guardian.email,
        'phoneNumber': guardian.phone,
      }).then((value) {
        print('Guardian saved to Firestore');
      }).catchError((error) {
        print('Failed to save guardian: $error');
      });
    }
  }

  void _saveEnrollmentToFirestore() {
    final firestore = Firestore.instance;
    final enrollmentDetailsCollection = firestore
        .collection('Students')
        .document(_studCMSIDController.text)
        .collection("Enrollments");

    enrollmentDetailsCollection.add({
      'StartDate': _dateController.text,
      'Class': _isReading ? "Reading" : (_isMath ? "Math" : "Other"),
      'EndDate': "",
    }).then((value) {
      print('Enrollment saved to Firestore');
    }).catchError((error) {
      print('Failed to save guardian: $error');
    });
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student details saved successfully.'),
        duration: Duration(seconds: 3),
        backgroundColor: Color.fromARGB(255, 94, 29, 216),
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student details saved successfully.'),
        duration: Duration(seconds: 3),
        backgroundColor: Color.fromARGB(255, 202, 75, 17),
      ),
    );
  }

  void _resetFields() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _studCMSIDController.clear();
      _studTCAIDController.clear();
      _dateController.clear();
      readingValue = null;
      mathValue = null;
      _isActive = false;
      _isReading = false;
      _isMath = false;
      firstNameValue = false;
      lastNameValue = false;
      studCMSIDValue = false;
      studTCAIDValue = false;
      guardianDetails = [];
    });
  }

  void _addStudent() async {
    if (_formKey.currentState!.validate()) {
      try {
        _formKey.currentState!.save();

        if (readingValue == null) {
          readingValue = '';
        }
        if (mathValue == null) {
          mathValue = '';
        }

        final firestore = Firestore.instance;
        final studentsCollection = firestore.collection('Students');
        final cmsStudentId = _studCMSIDController.text;

        final personalDetailsCollection =
            studentsCollection.document(cmsStudentId);

        await personalDetailsCollection.set({
          'FirstName': _firstNameController.text,
          'LastName': _lastNameController.text,
          'CMSStudentID': _studCMSIDController.text,
          'TCAStudentID': _studTCAIDController.text,
          'isReading': _isReading,
          'isMath': _isMath,
          'readingLocation': readingValue,
          'mathLocation': mathValue,
          'isActive': _isActive,
        });

        SnackBar(
          content: Text('Student details saved successfully.'),
          duration: Duration(seconds: 3),
          //backgroundColor: Color.fromARGB(255, 166, 216, 239),
        );

        _showSuccessMessage();
        _saveGuardiansToFirestore();
        _saveEnrollmentToFirestore();

        _resetFields();
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Student'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.0),

                Text(
                  'Student Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16.0),

                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a first name';
                    } else {
                      firstNameValue = true;
                    }
                  },
                  onSaved: (value) {
                    _firstNameController.text = value!;
                    setState(() {
                      firstNameValue = true;
                    });
                  },
                  //key: _firstNameFormKey,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a last name';
                    } else {
                      // setState(() {
                      //   lastNameValue=true;
                      //
                      // });
                    }
                  },
                  onSaved: (value) {
                    _lastNameController.text = value!;
                    lastNameValue = true;
                  },
                  //key: _lastNameFormKey,
                ),
                TextFormField(
                  controller: _studCMSIDController,
                  decoration: InputDecoration(
                    labelText: 'CMS Student ID',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    int? id = int.tryParse(value!);
                    if (value!.isEmpty) {
                      return 'Please enter a CMS student ID';
                    } else if (id == null) {
                      return 'Please enter an integer value';
                    } else {
                      // setState(() {
                      //   studCMSIDValue = true;
                      //
                      // });
                    }
                  },
                  onSaved: (value) {
                    _studCMSIDController.text = value!.toString();
                    studCMSIDValue = true;
                  },

                  //key: _studentIDFormKey,
                ),

                TextFormField(
                  controller: _studTCAIDController,
                  decoration: InputDecoration(
                    labelText: 'TCA Student ID',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    int? id = int.tryParse(value!);
                    if (value!.isEmpty) {
                      return 'Please enter a TCA student ID';
                    } else if (id == null) {
                      return 'Please enter an integer value';
                    } else {
                      // setState(() {
                      //   studTCAIDValue= true;
                      //
                      // });
                    }
                  },
                  onSaved: (value) {
                    _studTCAIDController.text = value!.toString();
                    studTCAIDValue = true;
                  },

                  //key: _studentIDFormKey,
                ),

                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  onTap: () {
                    dt.DatePicker.showDatePicker(
                      context,
                      showTitleActions: true,
                      onConfirm: (date) {
                        setState(() {
                          _dateController.text =
                              DateFormat('yyyy-MM-dd').format(date);
                        });
                      },
                    );
                  },
                ),

                CheckboxListTile(
                  title: Text('Is Reading'),
                  value: _isReading,
                  onChanged: (value) {
                    setState(() {
                      _isReading = value!;
                    });
                  },
                ),

                if (_isReading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Main Room',
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            Radio<String>(
                              value: 'Main Room',
                              groupValue: readingValue,
                              onChanged: (value) {
                                setState(() {
                                  readingValue = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Early Learner',
                            ),
                            SizedBox(
                              width: 42,
                            ),
                            Radio<String>(
                              value: 'Early Learner',
                              groupValue: readingValue,
                              onChanged: (value) {
                                setState(() {
                                  readingValue = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Primary Instruction',
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Radio<String>(
                              value: 'Primary Instruction',
                              groupValue: readingValue,
                              onChanged: (value) {
                                setState(() {
                                  readingValue = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                CheckboxListTile(
                  title: Text('Is Math'),
                  value: _isMath,
                  onChanged: (value) {
                    setState(() {
                      _isMath = value!;
                    });
                  },
                ),

                if (_isMath)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Main Room',
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            Radio<String>(
                              value: 'Main Room',
                              groupValue: mathValue,
                              onChanged: (value) {
                                setState(() {
                                  mathValue = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Early Learner',
                            ),
                            SizedBox(
                              width: 42,
                            ),
                            Radio<String>(
                              value: 'Early Learner',
                              groupValue: mathValue,
                              onChanged: (value) {
                                setState(() {
                                  mathValue = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Primary Instruction',
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Radio<String>(
                              value: 'Primary Instruction',
                              groupValue: mathValue,
                              onChanged: (value) {
                                setState(() {
                                  mathValue = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                CheckboxListTile(
                  title: Text('Is Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value!;
                    });
                  },
                ),
                SizedBox(height: 16.0),

                Text(
                  'Guadian Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: guardianDetails.length,
                  itemBuilder: (BuildContext context, int index) {
                    final guardian = guardianDetails[index];
                    return ListTile(
                      title: Text(
                          '${guardian.relation}: ${guardian.firstName} ${guardian.lastName}'),
                      subtitle: Text(
                          'Email: ${guardian.email}, Phone: ${guardian.phone}'),
                    );
                  },
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _addGuardian,
                  child: Text('Add Guardian'),
                ),

                // Center(
                //   child: QrImage(
                //     data: _data,
                //     version: QrVersions.auto,
                //     size: 200.0,
                //   ),
                // ),
                SizedBox(height: 20.0),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: saveQRImage,
                      child: const Text('Save QR'),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _addStudent();
                      },
                      child: Text('Add'),
                    ),
                    ElevatedButton(
                      onPressed: _resetFields,
                      child: Text('Reset'),
                    ),
                  ],
                ),

                SizedBox(height: 20.0),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _pickAndReadExcel,
                      child: const Text('Add excel file details'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future saveQRImage() async {
    FocusScope.of(context).unfocus();
    String? filePath = await FilePicker.platform.saveFile(
      fileName: _studCMSIDController.text + ".png",
      type: FileType.image,
    );
    if (filePath == null) {
      return;
    }

    final generator = QRGenerator();

    await generator.generate(
      data: _studCMSIDController.text,
      filePath: filePath,
      scale: 10,
      padding: 2,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      errorCorrectionLevel: ErrorCorrectionLevel.medium,
    );
  }
}
