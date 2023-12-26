import 'dart:io';

import 'package:csv/csv.dart';

class CsvHelper {
  static Future<List<List<dynamic>>> readCsv(String s) async {
    final file = File(s);
    if (await file.exists()) {
      final csvContent = await file.readAsString();
      return CsvToListConverter().convert(csvContent);
    }
    return [];
  }

  static Future<void> writeCsv(List<List<dynamic>> csvData, String s) async {
    final file = File(s);
    final csvContent = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvContent);
  }
}
