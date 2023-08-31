import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PhysicalActivityLog extends StatelessWidget {

  final String patientNumber; // Using the "?" makes it optional
  PhysicalActivityLog({required this.patientNumber});

  Future<List<ActivityEntry>> fetchActivityData(phoneNumber) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/activity_records/$phoneNumber'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((entry) {
        return ActivityEntry(
          intensity: entry['activity_type'],
          date: DateTime.parse(entry['date']),
          time: DateFormat('HH:mm:ss').parse(entry['time']),
        );
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color:Color(0xffF86851)),
        title: Text('Physical Activity Logs',style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xffF86851),
          ),
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<ActivityEntry>>(
          future: fetchActivityData(patientNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot);
              return Center(child: Text('Error fetching data'));
            } else {
              final ActivityData = snapshot.data!;
              // Sort the data by date
              ActivityData.sort((a, b) => b.date.compareTo(a.date));
              // Group the data by date
              Map<String, List<ActivityEntry>> groupedData = {};
              ActivityData.forEach((entry) {
                String key = DateFormat('yyyy-MM-dd').format(entry.date);
                groupedData.putIfAbsent(key, () => []);
                groupedData[key]?.add(entry);
              });

              return ListView.builder(
                itemCount: groupedData.length,
                itemBuilder: (context, index) {
                  String key = groupedData.keys.elementAt(index);
                  List<ActivityEntry> entries = groupedData[key]!;
                  return ListTile(
                    title: Text('Date: $key',style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6373CC),
                      ),
                    ),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.map((entry) {
                        String formattedTime = DateFormat('HH:mm').format(entry.time);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(
                            'Time: $formattedTime, Activity Intensity: ${entry.intensity}',style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}



class ActivityEntry {
  final String intensity;
  final DateTime date;
  final DateTime time;

  ActivityEntry({
    required this.intensity,
    required this.date,
    required this.time,
  });
}