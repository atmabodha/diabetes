import 'dart:io';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Forms/BloodReportLog.dart';

class BloodReport extends StatefulWidget {

  final String patientNumber; // Using the "?" makes it optional
  BloodReport({required this.patientNumber});

  @override
  State<BloodReport> createState() => _BloodReportState();
}

class _BloodReportState extends State<BloodReport> {


  Future<List<ReportEntry>> fetchReportData(phoneNumber) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/blood_reports/$phoneNumber'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((entry) {
        return ReportEntry(
          hba1c: entry['hba1c'],
          cholesterol: entry['cholesterol'],
          vd: entry['vitamind'],
          v12: entry['vitaminb12'],
          date: DateTime.parse(entry['date']),
          time: DateFormat('HH:mm:ss').parse(entry['time']),
        );
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  void openBloodReportEntryDialog(hb,chole,vd,v12) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return BloodReportLogBottomSheet(hb: hb,chole: chole,vd: vd,vb12: v12,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color:Color(0xffF86851)),
        title: Text('Blood Reports Logs',style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xffF86851),
          ),
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<ReportEntry>>(
          future: fetchReportData(widget.patientNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot);
              return Center(child: Text('Error fetching data'));
            } else {
              final ReportData = snapshot.data!;
              // Sort the data by date
              ReportData.sort((a, b) => b.date.compareTo(a.date));

              return ListView.builder(
                itemCount: ReportData.length,
                itemBuilder: (context, index) {

                  var data = ReportData[index];
                  String date = DateFormat('yyyy-MM-dd').format(data.date);
                  String time = DateFormat('HH:mm').format(data.time);

                  return ListTile(
                    onTap: (){
                      openBloodReportEntryDialog(data.hba1c,data.cholesterol,data.vd,data.v12);
                    },
                    title: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Color(0xffF2F2F2),
                        border:Border.all(
                        color: Color(0xff6373CC), // Set the desired border color here
                        width: 2.0, // Set the desired border width here
                      ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(date,style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff6373CC),
                                  ),
                                ),),
                                Text(time,style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffF86851),
                                  ),
                                ),),
                              ],
                            ),
                            Icon( Icons.arrow_forward_ios_outlined,color: Color(0xff6373CC) ,),
                          ],
                        ),
                      ),
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



class ReportEntry {
  final String hba1c;
  final DateTime date;
  final DateTime time;
  final String vd;
  final String v12;
  final String cholesterol;

  ReportEntry({
    required this.hba1c,
    required this.date,
    required this.time,
    required this.vd,
    required this.v12,
    required this.cholesterol,
  });
}