import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
