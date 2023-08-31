import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:diabetes_ms/Components/Forms/BloodReport.dart';
import 'package:diabetes_ms/Components/Forms/Insulin.dart';
import 'package:diabetes_ms/Components/Forms/MealInTake.dart';
import 'package:diabetes_ms/Screens/OnBoarding/ProfilePic.dart';
import 'package:diabetes_ms/Screens/Patient/Profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../Components/CustomListTitle.dart';
import '../../Components/Forms/Activity.dart';
import '../../Components/Forms/BloodGlucose.dart';
import 'ChangeProfilePic.dart';
import 'GraphsScreen.dart';
import 'cal.dart';

class HomeScreenP extends StatefulWidget {
  const HomeScreenP({super.key});

  @override
  State<HomeScreenP> createState() => _HomeScreenPState();
}

class _HomeScreenPState extends State<HomeScreenP> {
  late String phoneNumber;
  late SharedPreferences prefs;
  String _profilePicturePath = '';
  double _progress = 0;
  late DateTime _lastDate;


  final TextEditingController bloodSugarController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  String mealType = '';

  @override
  void initState() {
    super.initState();
    OnBoaringCompleted();
    _loadProgress();
  }

  // Function to mark onboarding as completed
  Future<void> OnBoaringCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    phoneNumber = prefs.getString('phoneNumber') ?? "";
    fetchUserData(phoneNumber);
  }


  // Convert base64 string to File
  File base64ToFile(String base64String) {
    Uint8List bytes = base64Decode(base64String);
    String tempPath = Directory.systemTemp.path;
    String fileName = 'profile_picture.png'; // Provide a suitable file name here
    File file = File('$tempPath/$fileName');
    file.writeAsBytesSync(bytes);
    return file;
  }

  // Fetch user data from the server
  Future<void> fetchUserData(phoneNumber) async {

    // Make a GET request to fetch user data
    // Set Provider values based on fetched data
    final url = 'http://10.0.2.2:5000/get_users/$phoneNumber';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      // print(data);
      context.read<UserProvider>().setName(data['name']);
      context.read<UserProvider>().setPhoneNumber(data['phoneNumber']);
      context.read<UserProvider>().setDateOfBirth(data['dateOfBirth']);
      context.read<UserProvider>().setCity(data['city']);
      context.read<UserProvider>().setGender(data['gender']);
      context.read<UserProvider>().setBloodGroup(data['bloodGroup']);
      context.read<UserProvider>().setFamilyHistory(data['familyHistory']);
      context.read<UserProvider>().setMedicalCondition(data['medicalCondition']);
      context.read<UserProvider>().setDoctorid(data['doctorid']);
      context.read<UserProvider>().setStatus(data['status']);

      File profilePicFile = base64ToFile(data['profilepic']);
      context.read<UserProvider>().setImageFile(profilePicFile);

    } catch (error) {
      print(error);
    }
  }

  // Open various entry dialogs
  void openBloodSugarEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return BloodSugarEntryBottomSheet();
      },
    );
  }


  void openInsulinEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return InsulinEntryBottomSheet();
      },
    );
  }

  void openMealIntakeEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return MealIntakeEntryBottomSheet();
      },
    );
  }

  void openActivityEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return ActivityEntryBottomSheet();
      },
    );
  }

  void openBloodReportEntryDialog() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return BloodReportEntryBottomSheet();
      },
    );
  }

  // Load user progress from shared preferences
  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double currentProgress = prefs.getDouble('userProgress') ?? 0;
    context.read<UserProvider>().setLog(currentProgress);
    DateTime? lastDate = DateTime.tryParse(prefs.getString('lastDate') ?? '');
    DateTime today = DateTime.now();

    if (lastDate == null || lastDate.day != today.day) {
      context.read<UserProvider>().setLog(0);
      currentProgress = 0;
    }

    setState(() {
      _lastDate = today;
    });
  }

  // Update user progress and store in shared preferences
  Future<void> _updateProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double updatedProgress = _progress + 1;
    context.read<UserProvider>().setLog(updatedProgress);
    await prefs.setDouble('userProgress', updatedProgress);
    await prefs.setString('lastDate', DateTime.now().toIso8601String());

    setState(() {
      _progress = updatedProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            String? firstName = userProvider.name;
                            if (firstName != null) {
                              List<String> nameParts = firstName.split(' ');
                              firstName = nameParts.first;
                            }

                            return Container(
                              padding: EdgeInsets.zero,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Welcome, ${userProvider.name} !",
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff6373CC),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          "Take charge of your health.",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xffF86851),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: Consumer<UserProvider>(
                        builder: (context, imageProvider, _) {
                          if (imageProvider.imageFile == null) {
                            return const CircleAvatar(
                              radius: 32,
                              backgroundImage: AssetImage(
                                  'assets/images/default_profile_pic.png'),
                            );
                          } else {
                            return CircleAvatar(
                                radius: 32,
                                backgroundImage:
                                    FileImage(imageProvider.imageFile!)
                                        as ImageProvider);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 45, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Progress",
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new CircularPercentIndicator(
                            radius: 60.0,
                            lineWidth: 10.0,
                            percent: context.read<UserProvider>().log! / 7,
                            center: new Text('${(context.read<UserProvider>().log! / 7).toStringAsFixed(2)}%'),
                            progressColor: Color(0xff6373CC),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Today's Progress",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "${(context.read<UserProvider>().log!).toInt()} out of 7 Completed",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffF86851)),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap : (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Cal()),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "Calculate Insulin\nIntake  >",
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:Color(0xff6373CC),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 45, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Track",
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/sugar.png'),
                            heading: 'Blood Sugar',
                            subheading: 'Keep Track of Your Blood Sugar Readings',
                            trailingIcon: Icons.add_box_rounded,
                            onTap: openBloodSugarEntryDialog,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/insulin.png'),
                            heading: 'Insulin Taken',
                            subheading: 'Keep a Record of Your Insulin Intake',
                            trailingIcon: Icons.add_box_rounded,
                            onTap: openInsulinEntryDialog,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/meal.png'),
                            heading: 'Meal Intake',
                            subheading: 'Keep Track of Your Daily Meal Intake',
                            trailingIcon: Icons.add_box_rounded,
                            onTap:openMealIntakeEntryDialog,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/physical_activity.png'),
                            heading: 'Physical Activity',
                            subheading: 'Record Your physical activity',
                            trailingIcon: Icons.add_box_rounded,
                            onTap: openActivityEntryDialog,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/blood.png'),
                            heading: 'Blood Report',
                            subheading: 'Record Your Blood Test Results',
                            trailingIcon: Icons.add_box_rounded,
                            onTap: openBloodReportEntryDialog,
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:Color(0xff6373CC),
        onPressed: () {
          // Navigate to another page when the floating button is pressed.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GraphScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(Icons.stacked_bar_chart_sharp),
              Text('Stats',style: TextStyle(fontSize: 12),),
            ],
          ),
        ),
      ),
    );
  }
}



