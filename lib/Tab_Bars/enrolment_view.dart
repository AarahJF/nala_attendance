import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../enrollment.dart';

class EnrolHistoryView extends StatefulWidget {
  List<Enrollment> enrollments;
  EnrolHistoryView(this.enrollments);

  @override
  State<EnrolHistoryView> createState() => _EnrolHistoryViewState();
}

class _EnrolHistoryViewState extends State<EnrolHistoryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          Table(
            border: TableBorder.all(
              color: Colors.blue,
              width: 1.0,
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                ),
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Class name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Start Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'End Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              for (var index = 0; index < widget.enrollments.length; index++)
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.enrollments[index].Class),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.enrollments[index].startDate),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.enrollments[index].endDate),
                      ),
                    ),
                  ],
                ),
              // Add more rows as needed
            ],
          ),
        ],
      ),
    );
  }
}
