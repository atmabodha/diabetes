import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Providers/UserInfo.dart';

class MealIntakeLog extends StatefulWidget {

  final String patientNumber; // Using the "?" makes it optional
  MealIntakeLog({required this.patientNumber});

  @override
  State<MealIntakeLog> createState() => _MealIntakeLogState();
}

class _MealIntakeLogState extends State<MealIntakeLog> {

  Future<List<MealIntakeEntry>> fetchMealData(phoneNumber) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/get_mealIntake/$phoneNumber'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.asMap().map((index, entry) {
        return MapEntry(
          index,
          MealIntakeEntry(
            meal_intake: entry['meal_intake'],
            date: DateTime.parse(entry['date']),
            time: DateFormat('HH:mm:ss').parse(entry['time']),
          ),
        );
      }).values.toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showImageDialog(BuildContext context, String image, String date, String time) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: FutureBuilder<bool>(
            future: _decodeAndSaveImage(image, date, time),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error loading image');
              } else {
                if (snapshot.data == true) {
                  String tempPath = Directory.systemTemp.path;
                  String fileName = 'profile_picture.png';
                  File imageFile = File('$tempPath/$fileName$date$time');
                  return Image(
                    image: FileImage(imageFile),
                  );
                } else {
                  return Text('Error decoding image');
                }
              }
            },
          ),
        );
      },
    );
  }


  Future<bool> _decodeAndSaveImage(String base64String, String date, String time) async {
    try {
      Uint8List bytes = base64Decode(base64String);
      String tempPath = Directory.systemTemp.path;
      String fileName = 'profile_picture.png';
      File file = File('$tempPath/$fileName$date$time');
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _fetchAndShowImage(date,time) async {
    // Replace this with your API endpoint to fetch the image URL based on mealId
    var phoneNumber = widget.patientNumber;
    String apiUrl = 'http://10.0.2.2:5000/get_foodpic/$date/$time/$phoneNumber';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        String base64Image = await responseData['foodpic'];
        print("Here!!!");
        _showImageDialog(context, base64Image,date,time);
      } else {
        // Handle error cases, such as non-200 response status
        // You can show an error message or handle it as per your requirement
      }
    } catch (e) {
      // Handle exceptions if any
      // You can show an error message or handle it as per your requirement
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xffF86851)),
        title: Text('Meal Intake Logs', style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xffF86851),
          ),
        ),),
      ),
      body: FutureBuilder<List<MealIntakeEntry>>(
        future: fetchMealData(widget.patientNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot);
            return Center(child: Text('Error fetching data'));
          } else {
            List<MealIntakeEntry> mealData = snapshot.data!;
            // You can use the mealData list here to build the UI
            return ListView.builder(
              itemCount: mealData.length,
              itemBuilder: (context, index) {
                String date = DateFormat('yyyy-MM-dd').format(mealData[index].date);
                String time = DateFormat('HH:mm').format(mealData[index].time);
                return ListTile(
                  onTap: (){
                    _fetchAndShowImage(date,time);
                  },
                  title: Text('Meal Intake: ${mealData[index].meal_intake}'),
                  subtitle: Text('Date: ${date} , Time: ${time}'),
                );
              },
            );
          }
        },
      ),

    );
  }
}



class MealIntakeEntry {
  final String meal_intake;
  final DateTime date;
  final DateTime time;

  MealIntakeEntry({
    required this.meal_intake,
    required this.date,
    required this.time,
  });
}