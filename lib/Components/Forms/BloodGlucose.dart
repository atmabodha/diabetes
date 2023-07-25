import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BloodSugarEntryBottomSheet extends StatefulWidget {
  @override
  _BloodSugarEntryBottomSheetState createState() =>
      _BloodSugarEntryBottomSheetState();
}

class _BloodSugarEntryBottomSheetState extends State<BloodSugarEntryBottomSheet> {

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String mealType = 'Before'; // Assuming 'Before' is the default value
  TextEditingController bloodSugarController = TextEditingController();

  void _onMealSelected(String type) {
    setState(() {
      mealType = type;
    });
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm(); // You can customize the time format here if needed.
    return format.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    'Blood Sugar Entry',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6373CC),
                        fontSize: 20,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Blood Sugar",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextField(
                      controller: bloodSugarController,
                      decoration: InputDecoration(labelText: 'Blood Sugar'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Time'),
                subtitle: Text(_formatTimeOfDay(selectedTime)),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null && picked != selectedTime)
                    setState(() {
                      selectedTime = picked;
                    });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meal Type:'),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _onMealSelected("Before"),
                          child: const Text('Before'),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: mealType == "Before"
                                  ? Colors.white
                                  : const Color(0xff6373CC),
                              backgroundColor: mealType == "Before"
                                  ? const Color(0xffF86851)
                                  : const Color(0xffD9D9D9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(100, 40)),
                        ),
                        ElevatedButton(
                          onPressed: () => _onMealSelected("After"),
                          child: const Text('After'),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: mealType == "After"
                                  ? Colors.white
                                  : const Color(0xff6373CC),
                              backgroundColor: mealType == "After"
                                  ? const Color(0xffF86851)
                                  : const Color(0xffD9D9D9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(100, 40)),
                        ),
                        ElevatedButton(
                          onPressed: () => _onMealSelected("Other"),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: mealType == "Other"
                                  ? Colors.white
                                  : const Color(0xff6373CC),
                              backgroundColor: mealType == "Other"
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
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        saveBloodSugarEntry();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF86851),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(100, 40)),
                      child: Text('Save'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF86851),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(100, 40)),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to save the blood sugar entry
  Future<void> saveBloodSugarEntry() async {

    // TO:DO WHAT IF THE SUGAR IS NULL

    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    String timeStr = selectedTime.format(context);

    // print(mealType);
    // print(bloodSugarController.text);
    // print(dateStr);
    // print(timeStr);

    final data = {
      'selectedDate': dateStr,
      'selectedTime': timeStr,
      'mealType': mealType,
      'bloodSugar': bloodSugarController.text,
    };

    final url = 'http://10.0.2.2:5000/save_blood_sugar';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      print('Blood sugar record saved successfully');
      // Handle success
    } else {
      print('Failed to save blood sugar record');
      // Handle error
    }
  }
}