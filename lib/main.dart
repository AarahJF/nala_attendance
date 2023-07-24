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
import 'package:nala_attendance/home_screen.dart';
import 'package:nala_attendance/qr_gen.dart';
import 'add_student.dart';
import 'custom_app_bar.dart';
import 'maintain_student_profiles.dart';

const apikey = 'AIzaSyDtQbhwUD2sSjLzz2PCKCpnfWwKqPoDDzg';
const projectId = 'nala-attendance';

void main(List<String> args) {
  Firestore.initialize(projectId);

  // Enable desktop platforms
  WidgetsFlutterBinding.ensureInitialized();
  if ([
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  // Set up the custom window title bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    systemNavigationBarColor: Colors.grey[50],
    statusBarColor: Colors.grey[50],
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
  ));

  if (args.firstOrNull == 'multi_window') {
    // runApp(MaintainStudentProfile());
  } else {
    // Run the app
    runApp(MyApp());
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int myIndex = 0;

  GlobalKey _bottomNavigationKey = GlobalKey();

  Widget bodyFunction() {
    switch (myIndex) {
      case 0:
        return HomeScreen();
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
        appBar: CustomAppBar(),
        body: bodyFunction(),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 75.0,
          items: <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.people, size: 30),
            Icon(Icons.add_card, size: 30),
            Icon(Icons.qr_code, size: 30),
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
