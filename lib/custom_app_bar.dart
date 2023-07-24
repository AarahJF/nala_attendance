
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {


  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  final Size preferredSize = Size.fromHeight(56.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String dropdownValue = '';


  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: Colors.grey[200],
      child: Row(
        children: [

          //Menu button for file
          TextButton(
            onPressed: () {
              showMenu(
                context: context,
                position:RelativeRect.fromLTRB(0, 40, 0, 0),
                items: [
                  PopupMenuItem(
                    child: Text('Import Enrollments from CMS'),
                    value: 'option1',
                  ),
                  PopupMenuItem(
                    child: Text('Exit'),
                    value: 'option2',
                  ),
                ],
              ).then((value) {
                setState(() {
                  if(value!=null){
                    dropdownValue = value;
                    if (value == 'option2') {
                      exit(0); // Close the window
                    }

                  }
                  else{
                    dropdownValue='';
                  }
                });
              });
            },
            child: Text(
              'File',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),


          //Menu button for Student
          TextButton(

            onPressed: () {

              showMenu(
                context: context,
                position:RelativeRect.fromLTRB(65, 40, 65, 0),
                items: [

                  PopupMenuItem(
                    child: Text('Add Student Details'),

                    onTap: () async {
                      // final window = await DesktopMultiWindow.createWindow(jsonEncode({
                      //   // You can add any additional properties you want to pass to the new window here
                      //   'args1': 'addStudWindow',
                      // }));
                      // await window.setFrame(const Offset(0, 0) & const Size(1280, 720));
                      // await window.center(
                      //
                      // );
                      // await window.setTitle('Maintain Student Profiles');
                      // await window.show();




                    },
                  ),



                  PopupMenuItem(
                    child: Text('Maintain Student Profiles'),

                    onTap: () async {
                      // final window = await DesktopMultiWindow.createWindow(jsonEncode({
                      //   // You can add any additional properties you want to pass to the new window here
                      //   'args1': 'maintainStudWindow',
                      // }));
                      // await window.setFrame(const Offset(0, 0) & const Size(1280, 720));
                      // await window.center(
                      //
                      // );
                      // await window.setTitle('Maintain Student Profiles');
                      // await window.show();



                    },
                  ),

                  // PopupMenuItem(
                  //   child: Text('Maintain Student Profiles'),
                  //   value: 'option3',
                  //   onTap: () async {
                  //     final window =
                  //     await DesktopMultiWindow.createWindow(jsonEncode({
                  //
                  //     }));
                  //     window
                  //       ..setFrame(const Offset(0, 0) & const Size(1280, 720))
                  //       ..center()
                  //       ..setTitle('Another window')
                  //       ..show();
                  //   },
                  // ),
                  PopupMenuItem(
                    child: Text('Maintain Student Schedule'),

                  ),
                  PopupMenuItem(
                    child: Text('Maintain Alerts and Notes'),
                    value: 'option5',
                  ),
                  PopupMenuItem(
                    child: Text('Print Student Barcodes'),
                    value: 'option6',
                  ),
                  PopupMenuItem(
                    child: Text('View Schedule'),
                    value: 'option7',
                  ),
                  PopupMenuItem(
                    child: Text('View Student Alerts and Notes'),
                    value: 'option8',
                  ),
                  PopupMenuItem(
                    child: Text('View Student Time in Center'),
                    value: 'option9',
                  ),
                  PopupMenuItem(
                    child: Text('View Student Arrival Time'),
                    value: 'option10',
                  ),
                  PopupMenuItem(
                    child: Text('Email "No Shows"'),
                    value: 'option11',
                  ),
                ],
              );
            },
            child: Text(
              'Student',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),


          //Menu button for Student
          TextButton(
            onPressed: () {
              showMenu(
                context: context,
                position:RelativeRect.fromLTRB(130, 40, 130, 0),
                items: [
                  PopupMenuItem(
                    child: Text('Option1'),
                    value: 'option1',
                  ),
                  PopupMenuItem(
                    child: Text('Option2'),
                    value: 'option2',
                  ),
                  PopupMenuItem(
                    child: Text('Option3'),
                    value: 'option3',
                  ),

                ],
              ).then((value) {
                setState(() {
                  if(value!=null){
                    dropdownValue = value;

                  }
                  else{
                    dropdownValue='';
                  }
                });
              });
            },
            child: Text(
              'Library',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          //Menu button for Staff
          TextButton(
            onPressed: () {
              showMenu(
                context: context,
                position:RelativeRect.fromLTRB(195, 40, 195, 0),
                items: [
                  PopupMenuItem(
                    child: Text('Maintain Time Records'),
                    value: 'option12',
                  ),
                  PopupMenuItem(
                    child: Text('View Payroll Report'),
                    value: 'option13',
                  ),
                  PopupMenuItem(
                    child: Text('Maintain Employees'),
                    value: 'option14',
                  ),
                  PopupMenuItem(
                    child: Text('Maintain Pay Scales'),
                    value: 'option15',
                  ),
                  PopupMenuItem(
                    child: Text('Maintain Payroll Schemes'),
                    value: 'option16',
                  ),
                ],
              ).then((value) {
                setState(() {
                  if(value!=null){
                    dropdownValue = value;

                  }
                  else{
                    dropdownValue='';
                  }
                });
              });
            },
            child: Text(
              'Staff',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,


              ),

            ),
          ),

          //Menu button for Staff
          TextButton(
            onPressed: () {
              showMenu(
                context: context,
                position:RelativeRect.fromLTRB(260, 40, 260, 0),
                items: [
                  PopupMenuItem(
                    child: Text('Refresh     F5'),
                    value: 'option17',
                  ),
                  PopupMenuItem(
                    child: Text('Set Color Scheme'),
                    value: 'option18',
                  ),
                  PopupMenuItem(
                    child: Text('Maintain Tables'),
                    value: 'option19',
                  ),
                  PopupMenuItem(
                    child: Text('Set up Center Defaults'),
                    value: 'option20',
                  ),
                  PopupMenuItem(
                    child: Text('Set up Email'),
                    value: 'option21',
                  ),
                  PopupMenuItem(
                    child: Text('Maintain Users'),
                    value: 'option22',
                  ),
                ],
              ).then((value) {
                setState(() {
                  if(value!=null){
                    dropdownValue = value;

                  }
                  else{
                    dropdownValue='';
                  }
                });
              });
            },
            child: Text(
              'System',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,


              ),

            ),
          ),


          //Menu button for Staff
          TextButton(
            onPressed: () {
              showMenu(
                context: context,
                position:RelativeRect.fromLTRB(325, 40, 325, 0),
                items: [
                  PopupMenuItem(
                    child: Text('Option 1'),
                    value: 'option1',
                  ),
                  PopupMenuItem(
                    child: Text('Option 2'),
                    value: 'option2',
                  ),

                ],
              ).then((value) {
                setState(() {
                  if(value!=null){
                    dropdownValue = value;

                  }
                  else{
                    dropdownValue='';
                  }
                });
              });
            },
            child: Text(
              'Help',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,


              ),

            ),
          ),



        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(40.0);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }


}
