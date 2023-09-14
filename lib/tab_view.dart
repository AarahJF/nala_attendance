import 'package:firedart/firestore/firestore.dart';
import 'package:firedart/firestore/models.dart';
import 'package:flutter/material.dart';
import 'package:nala_attendance/enrollment.dart';
import 'package:nala_attendance/guardian.dart';
import 'package:nala_attendance/schedule.dart';
import 'package:intl/intl.dart';
import 'package:nala_attendance/week_picker.dart';
import 'Attendance.dart';
import 'Data_Structures/student_schedule.dart';
import 'Tab_Bars/attendance_view.dart';
import 'Tab_Bars/default_view.dart';
import 'Tab_Bars/enrolment_view.dart';
import 'Tab_Bars/schedule_view.dart';
import 'duration.dart';
import 'package:table_calendar/table_calendar.dart';

class TabbedContainer extends StatefulWidget {
  final List<Guardian> guardians;
  final List<StudSchedule> studSchedule;
  final bool isReading;
  final bool isDoingMath;
  final String CMSID;
  final String name;

  TabbedContainer(this.guardians, this.studSchedule, this.isReading,
      this.isDoingMath, this.CMSID, this.name);

  @override
  _TabbedContainerState createState() => _TabbedContainerState();
}

class _TabbedContainerState extends State<TabbedContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  var timeDiff;
  int? _selectedIndex = 0;

  List<TextEditingController> startTimeControllers = [];
  List<TextEditingController> endTimeControllers = [];

  List<Schedule> regularSchedule = []; // List to store Regular Schedule
  List<Schedule> overideSchedule = []; // List to store Regular Schedule

  List<Enrollment> enrollments = [];
  // final CollectionReference enrollmentRef = Firestore.instance.collection('Students').document(widget.CMSID).collection("Enrollments");

  List<Attendance> attendanceList = [];
  String selectedWeek =
      ''; // Global variable to store the selected week details

  void getEnrollments(String cmsStudentId) async {
    final firestore = Firestore.instance;
    final enrollmentDetailsCollection = firestore
        .collection('Students')
        .document(widget.CMSID)
        .collection("Enrollments");

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
    final regularDetailsCollection = firestore
        .collection('Students')
        .document(widget.CMSID)
        .collection("Regular Schedule");

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

        startTimeControllers
            .add(TextEditingController(text: data['startTime']));
        endTimeControllers.add(TextEditingController(text: data['endTime']));

        regularSchedule.add(schedule);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void getStudents() async {
    List<Attendance> attendancelist = [];
    final CollectionReference studentsRef = Firestore.instance
        .collection("Students")
        .document(widget.CMSID)
        .collection("Attendance");

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
      regularSchedule = [];
      getregSchedule(widget.CMSID);
    });

    getStudents();
    getEnrollments(widget.CMSID);

    // Initialize the controllers for the existing rows in regularSchedule
    for (int i = 0; i < regularSchedule.length; i++) {
      startTimeControllers
          .add(TextEditingController(text: regularSchedule[i].startTime));
      endTimeControllers
          .add(TextEditingController(text: regularSchedule[i].endTime));
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
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem(0, 'Default'),
                _buildTabItem(1, 'Schedule'),
                _buildTabItem(2, 'Enrollment History'),
                _buildTabItem(3, 'Attendance'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DefaultView(widget.guardians),
                ScheduleView(
                  regularSchedule,
                  startTimeControllers,
                  endTimeControllers,
                  widget.CMSID,
                  widget.isDoingMath,
                  widget.isReading,
                  widget.name,
                ),
                EnrolHistoryView(enrollments),
                AttendanceView(attendanceList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (mounted) {
            _tabController.animateTo(index);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        color: _selectedIndex == index ? Colors.white : Colors.transparent,
        child: Text(
          text,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.blue : Colors.white,
          ),
        ),
      ),
    );
  }
}
