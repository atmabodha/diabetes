import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:diabetes_ms/Screens/Doctor/PatientApproval.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'DoctorGraphScreen.dart';

class HomeScreenD extends StatefulWidget {
  const HomeScreenD({super.key});

  @override
  State<HomeScreenD> createState() => _HomeScreenDState();
}

class _HomeScreenDState extends State<HomeScreenD> {

  // List of patients retrieved from the server
  List<Map<String, dynamic>> _patients = [];
  late String doctorId = '';
  TextEditingController _searchController = TextEditingController();


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

  // Function to fetch patients data for the doctor
  Future<List<Map<String, dynamic>>> _fetchPatientsData(doctorId) async {
    final url = 'http://10.0.2.2:5000/approved_patients/$doctorId';
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
        children: [
          Container(
            color: Color(0xff6373CC),
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Approval(),
                              ),
                            ),
                        child: Icon(
                          Icons.notifications_none_outlined,
                          size: 35,
                          color: Colors.white,
                        )),
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
                            Container(
                              padding: EdgeInsets.zero,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Welcome Back,",
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.zero,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Doctor ${userProvider.name} !",
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0,right: 15.0,top: 15.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Search Patients...',
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
                      suffixIcon:Icon(Icons.search),
                    ),
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {}); // To trigger a re-render and apply the filter
                    },
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
                        List<Map<String, dynamic>> filteredPatients = patients.where((patient) {
                          String name = patient['name'].toString().toLowerCase();
                          String phoneNumber = patient['phoneNumber'].toString().toLowerCase();
                          String gender = patient['gender'].toString().toLowerCase();
                          String searchTerm = _searchController.text.toLowerCase();
                          return name.contains(searchTerm) ||
                              phoneNumber.contains(searchTerm) ||
                              gender.contains(searchTerm);
                        }).toList();
                        return ListView.builder(
                          itemCount: filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = filteredPatients[index];
                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                  padding: EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey), // Add border around the ListTile
                                  borderRadius: BorderRadius.circular(8.0), // Optionally, add border radius
                                ),
                                child: ListTile(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GraphScreenD(patientNumber: patient['phoneNumber'],),
                                      ),
                                    );
                                  },
                                  title: Text(
                                    patient['name'],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffF86851),
                                      ),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                  // Add more patient details to display in the list as needed
                                ),
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
          ),

        ],
      ),
    );
  }
}
