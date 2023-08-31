import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Patient/HomeScreenP.dart';
import 'HomeScreenD.dart';

class Approval extends StatefulWidget {
  const Approval({super.key});

  @override
  State<Approval> createState() => _ApprovalState();
}

class _ApprovalState extends State<Approval> {

  // List of pending patients
  List<Map<String, dynamic>> _patients = [];
  late String doctorId = '';

  @override
  void initState() {
    super.initState();
    OnBoaringCompleted();
  }

  // Function to mark onboarding as completed and fetch user data
  Future<void> OnBoaringCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    var phoneNumber = prefs.getString('phoneNumber') ?? "";
    fetchUserData(phoneNumber);
  }

  // Function to fetch user data from the server
  Future<void> fetchUserData(phoneNumber) async {
    final url = 'http://10.0.2.2:5000/get_doctors_by_number/$phoneNumber';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      context.read<UserProvider>().setName(data['name']);
      doctorId = data['email'];
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  // Function to fetch pending patients data for the doctor
  Future<List<Map<String, dynamic>>> _fetchPatientsData(doctorId) async {
    final url = 'http://10.0.2.2:5000/pending_patients/$doctorId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load patients data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreenD()),
                          );
                        },
                        child: Icon(Icons.keyboard_backspace,
                            size: 35, color: Color(0xff6373CC))),
                    SizedBox(
                      height: 30,
                    ),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        String? firstName = userProvider.name;
                        if (firstName != null) {
                          List<String> nameParts = firstName.split(' ');
                          firstName = nameParts.first;
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                padding: EdgeInsets.zero,
                                child: FittedBox(
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "New Request",
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff6373CC),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPatientsData(doctorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No patients data found'));
                } else {
                  final patients = snapshot.data!;
                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];

                      // Extract phone number from patient data
                      String phoneNumber = patient['phoneNumber'];

                      // Function to handle the correct icon click
                      Future<void> onCorrectIconClick() async {
                        final apiUrl = 'http://10.0.2.2:5000/update_status1';
                        final headers = {'Content-Type': 'application/json'};
                        final body = json.encode({'phone_number': phoneNumber});

                        try {
                          final response = await http.post(Uri.parse(apiUrl),
                              headers: headers, body: body);

                          if (response.statusCode == 200) {
                            print('Status updated successfully');
                            setState(() {});
                          } else {
                            print('Failed to update status: ${response.body}');
                          }
                        } catch (error) {
                          print('Error: $error');
                        }
                        print('Correct icon clicked for phone number: $phoneNumber');
                      }

                      // Function to handle the wrong icon click
                      Future<void> onWrongIconClick() async {
                        // Implement your logic when the wrong icon is clicked
                        final apiUrl = 'http://10.0.2.2:5000/update_status2';
                        final headers = {'Content-Type': 'application/json'};
                        final body = json.encode({'phone_number': phoneNumber});

                        try {
                          final response = await http.post(Uri.parse(apiUrl),
                              headers: headers, body: body);

                          if (response.statusCode == 200) {
                            print('Status updated successfully');
                            setState(() {});
                          } else {
                            print('Failed to update status: ${response.body}');
                          }
                        } catch (error) {
                          print('Error: $error');
                        }
                        print('Wrong icon clicked for phone number: $phoneNumber');
                      }

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Text(
                            patient['name'],
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffF86851),
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone No.: ${patient['phoneNumber']}',
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Gender: ${patient['gender']}',
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: onCorrectIconClick,
                                icon: Icon(Icons.check, color: Colors.green,size: 30,),
                              ),
                              IconButton(
                                onPressed: onWrongIconClick,
                                icon: Icon(Icons.close, color: Colors.red,size: 30,),
                              ),
                            ],
                          ),
                          // Add more patient details to display in the list as needed
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
