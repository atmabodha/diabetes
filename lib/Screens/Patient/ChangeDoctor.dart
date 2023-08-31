import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:diabetes_ms/Screens/OnBoarding/ProfilePic.dart';
import 'package:diabetes_ms/Screens/Patient/HomeScreenP.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/DoctorCard.dart';

class ChangeYourDoctor extends StatefulWidget {
  @override
  _ChangeYourDoctorState createState() => _ChangeYourDoctorState();
}

class _ChangeYourDoctorState extends State<ChangeYourDoctor> {
  List<Map<String, dynamic>> doctors = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch doctor data when the widget is created
  }

  // Edit the selected doctor for the current user
  void EditDoctor() async {
    // Get user's phone number and doctor's email from context
    var phoneNumber = context.read<UserProvider>().phoneNumber;
    var email = context.read<UserProvider>().doctorid;

    final data = {
      "phoneNumber": phoneNumber,
      "doctorid": email,
    };

    // Send a POST request to edit the doctor for the user
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/edit_doctor'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      print("Edit Successfully");
    } else {
      print('Failed to edit.');
    }
  }

  // Fetch available doctors from the server
  void fetchData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/get_doctors'));
    if (response.statusCode == 200) {
      setState(() {
        final jsonData = json.decode(response.body);
        doctors = List<Map<String, dynamic>>.from(jsonData['doctors']);
      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Text(
                "Select Your Doctor",
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                      color: Color(0xff6373CC),
                      fontWeight: FontWeight.bold,
                      fontSize: 32),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    child: ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
                        return DoctorCard(
                          name: doctor['name'],
                          email: doctor['email'],
                          hospitalName: doctor['hospitalName'],
                          city: doctor['city'],
                          onTap: () {
                            // Set the selected doctor's email in the provider
                            context.read<UserProvider>().setDoctorid(doctor['email']);
                            // Edit the doctor for the user
                            EditDoctor();
                            // Navigate to the patient's home screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreenP(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}