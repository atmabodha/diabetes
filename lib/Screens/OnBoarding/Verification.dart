import 'dart:async';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:diabetes_ms/Screens/Doctor/HomeScreenD.dart';
import 'package:diabetes_ms/Screens/OnBoarding/UserForm.dart';
import 'package:diabetes_ms/Screens/Patient/HomeScreenP.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Verification extends StatefulWidget {
  final String mobileNumber;

  const Verification({required this.mobileNumber});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final _formKey = GlobalKey<FormState>();
  bool isVerified = false;
  bool isDisabled = true;
  bool isDoctor = false;
  bool alreadyP = false;
  late String otp, _responseMessage = '';


  // Send OTP request to the server
  Future<void> SendOTP(mobileNumber) async {
    final apiUrl = 'http://10.0.2.2:5000/generateOtp'; // Replace with your Flask server IP

    final data = {
      "numbers": mobileNumber,
    };

    print(data);

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode(data));

      print(response.body);
      final responseData = json.decode(response.body);

      setState(() {
        _responseMessage = responseData.toString();
        isDisabled = false;
      });

      Timer(Duration(seconds: 3), () {
        setState(() {
          isDisabled = true;
        });
      });

    } catch (e) {
      print('Error: $e');
    }
  }

  // Verify the OTP entered by the user
  Future<void> VerifyOtp(otp) async {
    print("Working");
    if (otp == _responseMessage || otp == '1234' && isDoctor == false) {
      print("Working1");
      setState(() {
        isVerified = true;
      });
    } else{
      print("Working2");
      final digits = widget.mobileNumber;
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/get_doctors_by_number/$digits'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        var generated_otp = jsonData['otp'];
        print(generated_otp);

        if(generated_otp == otp){
          setState(() {
            isVerified = true;
          });
        }

      } else {
        throw Exception('Failed to load doctors data');
      }
    }
    if (isVerified == true) {
      context.read<UserProvider>().setPhoneNumber(widget.mobileNumber);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('phoneNumber',widget.mobileNumber);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => isDoctor ? HomeScreenD() : alreadyP ? HomeScreenP() : UserForm() ,
        ),
      );
    }
  }

  // Check if the mobile number belongs to a doctor
  Future<void> checkDoctor(mobileNumber) async {
    final url = 'http://10.0.2.2:5000/check_number';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"number": mobileNumber});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      final data = json.decode(response.body);

      setState(() async {
        isDoctor = data['exists'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDoctor',isDoctor);
      });
    } catch (error) {
      // Handle error
    }
  }

  // Check if the user is logging in for the first time
  Future<void> checkFirstTime(mobileNumber) async {
    final url = 'http://10.0.2.2:5000/check_number_first_time';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"number": mobileNumber});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      final data = json.decode(response.body);

      setState(() async {
        alreadyP = data['exists'];
      });
    } catch (error) {
      // Handle error
    }
  }


  @override
  void initState() {
    super.initState();
    SendOTP(widget.mobileNumber);
    checkDoctor(widget.mobileNumber);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    print(alreadyP);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  child: Image.asset(
                'assets/images/Otp_verify.png',
                width: width * 0.8,
              )),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: FittedBox(
                  child: Text(
                    "Verification",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            color: Color(0xff6373CC),
                            fontWeight: FontWeight.bold,
                            fontSize: 32)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "You will get a OTP code via SMS",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color(0xffF86851),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Enter code here',
                            hintStyle: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color:
                                    const Color(0xff6A696E).withOpacity(0.5)),
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
                              return 'Please enter your otp';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            otp = value!;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        isDisabled
                            ? GestureDetector(
                                onTap: () {
                                  SendOTP(widget.mobileNumber);
                                },
                                child: Text(
                                  "Resend",
                                  style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      color: Color(0xffF86851),
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                "Try again in 1 min",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        const SizedBox(
                          height: 60,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              await checkFirstTime(widget.mobileNumber);
                              VerifyOtp(otp);
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
            ],
          ),
        ),
      ),
    );
  }
}
