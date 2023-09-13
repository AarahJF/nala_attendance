class StudSchedule {
  final String name;
  final String subject;
  final String location;
  final String startTime;
  final int timediff;
  final String week;
  final String day;

  StudSchedule({
    required this.startTime,
    required this.timediff,
    required this.location,
    required this.name,
    required this.subject,
    required this.week,
    required this.day,
  });
}
