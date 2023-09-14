import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ScheduleDuration extends StatefulWidget {
  final String? endTime;
  final String? startTime;
  final String? timediff;

  const ScheduleDuration(
      {Key? key, this.endTime, this.startTime, this.timediff})
      : super(key: key);

  @override
  _ScheduleDurationState createState() => _ScheduleDurationState();
}

class _ScheduleDurationState extends State<ScheduleDuration> {
  Duration? duration;

  @override
  void initState() {
    super.initState();
    calculateDuration();
  }

  @override
  void didUpdateWidget(covariant ScheduleDuration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.endTime != oldWidget.endTime ||
        widget.startTime != oldWidget.startTime) {
      calculateDuration();
    }
  }

  void calculateDuration() {
    if (widget.endTime != null && widget.startTime != null) {
      final endTime = DateFormat.Hm().parse(widget.endTime!);
      final startTime = DateFormat.Hm().parse(widget.startTime!);
      final difference = endTime.difference(startTime);
      duration = Duration(
          hours: difference.inHours,
          minutes: difference.inMinutes.remainder(60));
    } else {
      duration = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        '${duration != null ? duration!.inMinutes : (widget.timediff != null ? widget.timediff : 'N/A')}');
  }
}
