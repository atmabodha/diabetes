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

class SelectYourDoctor extends StatefulWidget {
  @override
  _SelectYourDoctorState createState() => _SelectYourDoctorState();
}

class _SelectYourDoctorState extends State<SelectYourDoctor> {
  List<Map<String, dynamic>> doctors = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Convert image to base64 format
  String imageToBase64(File imageFile) {
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  // Function to add user data to the server
  Future<void> addUser() async {

    var name = context.read<UserProvider>().name;
    var phoneNumber = context.read<UserProvider>().phoneNumber;
    var dateOfBirth = context.read<UserProvider>().dateOfBirth;
    var city = context.read<UserProvider>().city;
    var gender = context.read<UserProvider>().gender;
    var bloodGroup = context.read<UserProvider>().bloodGroup;
    var familyHistory = context.read<UserProvider>().familyHistory;
    var medicalCondition = context.read<UserProvider>().medicalCondition;
    var doctorid = context.read<UserProvider>().doctorid;
    var profilepic = context.read<UserProvider>().imageFile;
    var image = imageToBase64(profilepic!);

    final data = {
      "name": name,
      "phoneNumber": phoneNumber,
      "dateOfBirth": dateOfBirth,
      "gender": gender,
      "city": city,
      "medicalCondition": medicalCondition,
      "familyHistory": familyHistory,
      "bloodGroup": bloodGroup,
      "status": 0,
      "doctorid": doctorid,
      "image": image,
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      print("Created Successfully");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingCompleted',true);
    } else {
      print('Failed to add user.');
    }
  }

  // Fetch list of doctors from the server
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
                          onTap: () async {
                            // Add your onTap functionality here
                            context.read<UserProvider>().setDoctorid(doctor['email']);
                            await addUser();
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


// Widget for displaying doctor information
class DoctorCard extends StatelessWidget {
  final String name;
  final String email;
  final String hospitalName;
  final String city;
  final VoidCallback onTap;

  DoctorCard({
    required this.name,
    required this.email,
    required this.hospitalName,
    required this.city,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.blue, width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListTile(
            onTap: onTap,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name : $name",
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xffF86851),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(email),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospitalName),
                    SizedBox(height: 10.0),
                    Text(city),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
