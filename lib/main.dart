import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart'
    show
        TargetPlatform,
        debugDefaultTargetPlatformOverride,
        defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:nala_attendance/home_screen.dart';
import 'package:nala_attendance/qr_gen.dart';
import 'Data_Structures/student_schedule.dart';
import 'Schedule_Viewer.dart';
import 'add_student.dart';
import 'custom_app_bar.dart';
import 'maintain_student_profiles.dart';

const apikey = 'AIzaSyDtQbhwUD2sSjLzz2PCKCpnfWwKqPoDDzg';
const projectId = 'nala-attendance';

void main(List<String> args) {
  Firestore.initialize(projectId);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int myIndex = 0;
  String selectedDay = '';
  String selectedWeek = '';
  List<StudSchedule> scheduleList = []; // List to store Regular Schedule

  bool isLoading = true; // Add a flag to track loading

  String _getCurrentDay() {
    DateTime now = DateTime.now();
    return DateFormat('EEEE')
        .format(now); // Format the current date to get the day
  }

  String getFormattedCurrentWeek() {
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    DateTime sunday = monday.add(Duration(days: 6));

    String formattedMonday = DateFormat('yyyy / MM / dd').format(monday);
    String formattedSunday = DateFormat('yyyy / MM / dd').format(sunday);

    return "$formattedMonday - $formattedSunday";
  }

  void getSchedule() async {
    final firestore = Firestore.instance;
    final studentCollection = firestore.collection('Schedule');

    try {
      final studentlist = await studentCollection.get();

      scheduleList.clear(); // Clear the previous schedule data
      for (final data in studentlist) {
        //print(data);

        final schedule = StudSchedule(
            startTime: data['startTime'],
            location: data['location'],
            name: data['name'],
            subject: data['subject'],
            week: data['week'],
            day: data['day'],
            timediff: data['timediff']);

        scheduleList.add(schedule);
      }
      // Set isLoading to false once data is loaded
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle errors here
      // Set isLoading to false even in case of error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    selectedDay = _getCurrentDay();
    selectedWeek = getFormattedCurrentWeek();
    getSchedule();

    super.initState();
  }

  GlobalKey _bottomNavigationKey = GlobalKey();

  Widget bodyFunction() {
    switch (myIndex) {
      case 0:
        return HomeScreen(
          studSchedule: scheduleList,
          selectedDay: selectedDay,
          selectedWeek: selectedWeek,
        );
        break;
      case 1:
        return Container(
          child: MaintainStudentProfile(),
        );
        break;
      case 2:
        return Container(
          child: AddStudentPage(),
        );
      case 3:
        return Container(
          child: QRCodeGenerator(
            title: 'Generate QR Code',
          ),
        );
        break;
      case 4:
        return Container(
          child: ScheduleViewPage(
            studSchedule: scheduleList,
          ),
        );
        break;
      default:
        return Container(color: Colors.white);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug label
      title: 'TCA - The Center Administrator',
      theme: ThemeData.light(),
      home: Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : bodyFunction(), // Show data or other widgets once loading is done
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 75.0,
          items: <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.people, size: 30),
            Icon(Icons.add_card, size: 30),
            Icon(Icons.qr_code, size: 30),
            Icon(Icons.schedule, size: 30),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
        ),
      ),
    );
  }
}
