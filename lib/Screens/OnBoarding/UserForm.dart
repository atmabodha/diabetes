import 'package:diabetes_ms/Screens/OnBoarding/MedicalHistory.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../Providers/UserInfo.dart';
import 'package:intl/intl.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {

  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phoneNumber;
  late DateTime _dateOfBirth = DateTime.now();
  late String _gender = "Male";
  late String _city;

  void _onGenderSelected(String gender) {
    setState(() {
      _gender = gender;
    });
  }

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
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Account",
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
                        "Join our app to effortlessly manage and monitor your diabetes like never before!",
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
                        "Name",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xff6373CC),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Your Name',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                          context.read<UserProvider>().setName(value);
                        },
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
                        "Gender",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xff6373CC),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => _onGenderSelected("Male"),
                            child: const Text('Male'),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: _gender == "Male"
                                    ? Colors.white
                                    : const Color(0xff6373CC),
                                backgroundColor: _gender == "Male"
                                    ? const Color(0xffF86851)
                                    : const Color(0xffD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(100, 40)),
                          ),
                          ElevatedButton(
                            onPressed: () => _onGenderSelected("Female"),
                            child: const Text('Female'),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: _gender == "Female"
                                    ? Colors.white
                                    : const Color(0xff6373CC),
                                backgroundColor: _gender == "Female"
                                    ? const Color(0xffF86851)
                                    : const Color(0xffD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(100, 40)),
                          ),
                          ElevatedButton(
                            onPressed: () => _onGenderSelected("Other"),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: _gender == "Other"
                                    ? Colors.white
                                    : const Color(0xff6373CC),
                                backgroundColor: _gender == "Other"
                                    ? const Color(0xffF86851)
                                    : const Color(0xffD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(100, 40)),
                            child: const Text('Other'),
                          ),
                        ],
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
                        "Date Of Birth",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xff6373CC),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Date'),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(_dateOfBirth)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _dateOfBirth,
                            firstDate: DateTime(1900, 1, 1),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != _dateOfBirth)
                            setState(() {
                              _dateOfBirth = picked;
                            });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "City",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xff6373CC),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Your City',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _city = value!;
                          context.read<UserProvider>().setCity(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 60,),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        String dobFormatted = DateFormat('yyyy-MM-dd').format(_dateOfBirth);
                        context.read<UserProvider>().setDateOfBirth(dobFormatted);
                        context.read<UserProvider>().setGender(_gender);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MedicalHistory(),
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
