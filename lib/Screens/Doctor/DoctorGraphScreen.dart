import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Components/Graphs/BloodSugarGraph.dart';
import '../../Components/Graphs/InuslinGraph.dart';
import '../../Components/Log/BloodReport.dart';
import '../../Components/Log/MealIntakeLog.dart';
import '../../Components/Log/PhysicalActivityLog.dart';
import '../../Components/RectangleButton.dart';

class GraphScreenD extends StatefulWidget {

  final String patientNumber;
  GraphScreenD({super.key,required this.patientNumber});

  @override
  State<GraphScreenD> createState() => _GraphScreenDState();
}

class _GraphScreenDState extends State<GraphScreenD> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,color:Color(0xff6373CC),),
                      onPressed: () {
                        // Pop the current context to navigate back when the back icon is pressed.
                        Navigator.pop(context);
                      },
                    ),
                    Center(
                      child: Text(
                        "Select Your Graph",
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            color: Color(0xff6373CC),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 50, left: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          RoundedVerticalRectangle(
                            icon: Image.asset('assets/images/sugar.png'),
                            heading: 'Blood Sugar',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BloodSugarGraph(patientNumber: widget.patientNumber,),
                                ),
                              );
                            },
                          ),
                          RoundedVerticalRectangle(
                            icon: Image.asset(
                              'assets/images/insulin.png',
                            ),
                            heading: 'Insulin Taken',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InsulinGraph(patientNumber: widget.patientNumber,),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          RoundedVerticalRectangle(
                            icon: Image.asset('assets/images/meal.png'),
                            heading: 'Meal Intake',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MealIntakeLog(patientNumber: widget.patientNumber),
                                ),
                              );
                            },
                          ),
                          RoundedVerticalRectangle(
                            icon: Image.asset(
                                'assets/images/physical_activity.png'),
                            heading: 'Physical Activity',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhysicalActivityLog(patientNumber: widget.patientNumber),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          RoundedVerticalRectangle(
                            icon: Image.asset('assets/images/blood.png'),
                            heading: 'Blood Report',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BloodReport(patientNumber: widget.patientNumber),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
