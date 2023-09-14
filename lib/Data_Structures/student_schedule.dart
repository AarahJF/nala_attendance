class StudSchedule {
  String name;
  String subject;
  String location;
  String startTime;
  int timediff;
  String week;
  String cmsID;
  String day;

  StudSchedule({
    required this.startTime,
    required this.timediff,
    required this.location,
    required this.name,
    required this.cmsID,
    required this.subject,
    required this.week,
    required this.day,
  });
}
