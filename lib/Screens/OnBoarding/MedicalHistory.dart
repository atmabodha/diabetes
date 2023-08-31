import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ProfilePic.dart';
import 'SelectYourDoctor.dart';

class MedicalHistory extends StatefulWidget {
  const MedicalHistory({super.key});

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {

  final _formKey = GlobalKey<FormState>();
  String _medicalCondition = "";
  String? familyHistory;
  String _bloodGroup = "";
  String? selectedBloodGroup;
  List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  List<String> familyBackground = ['Yes', 'No'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Medical Information",
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                              color: Color(0xff6373CC),
                              fontWeight: FontWeight.bold,
                              fontSize: 32),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Let us get to know you better",
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xffF86851),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Blood Group",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xff6373CC),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedBloodGroup,
                        items: bloodGroups.map((String bloodGroup) {
                          return DropdownMenuItem<String>(
                            value: bloodGroup,
                            child: Text(bloodGroup),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBloodGroup = newValue!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select Blood Group',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Medical History",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xff6373CC),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Your Medical History',
                          hintStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: const Color(0xff6A696E).withOpacity(0.5)),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xffF86851),
                            ),
                            borderRadius:
                                BorderRadius.circular(10.0), // Border radius
                          ),
                        ),
                        onSaved: (value) {
                          _medicalCondition = value!;
                          context.read<UserProvider>().setMedicalCondition(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Diabetes Family Background",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xff6373CC),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<String>(
                        value: familyHistory,
                        items: familyBackground.map((String bloodGroup) {
                          return DropdownMenuItem<String>(
                            value: bloodGroup,
                            child: Text(bloodGroup),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            familyHistory = newValue!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Yes or No',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100,),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        if(selectedBloodGroup != null){
                          print("working");
                          context.read<UserProvider>().setBloodGroup(selectedBloodGroup!);
                        } else{
                          print("working else");
                          context.read<UserProvider>().setBloodGroup("");
                        }
                        if(familyHistory != null){
                          context.read<UserProvider>().setFamilyHistory(familyHistory!);
                        } else{
                          context.read<UserProvider>().setFamilyHistory("");
                        }
                        context.read<UserProvider>().setMedicalCondition(_medicalCondition);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePic(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6373CC),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize:
                      Size(MediaQuery.of(context).size.width, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 16,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
