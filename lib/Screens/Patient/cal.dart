import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recommended_page.dart'; // Import the RecommendedPage class

class Cal extends StatefulWidget {
  @override
  _CalState createState() => _CalState();
}

class _CalState extends State<Cal> {
  String activityDropdownValue = 'No';

  double? icf;
  double? icr;
  double? targetInsulinLevel;
  double? insulinDuration;

  TextEditingController carbohydratesController = TextEditingController();
  TextEditingController sugarLevelController = TextEditingController();
  TextEditingController isfController = TextEditingController();
  TextEditingController totalInsulinDoseController = TextEditingController();
  TextEditingController elapsedTimeController = TextEditingController();
  TextEditingController insulinDurationController = TextEditingController();
  TextEditingController icfController = TextEditingController();
  TextEditingController icrController = TextEditingController();
  TextEditingController targetInsulinController = TextEditingController();

  String activityIntensity = ''; // Store the selected activity intensity

  bool isEditingICF = false;
  bool isEditingICR = false;
  bool isEditingTargetInsulin = false;
  bool isEditingTotalInsulinDose = false;
  bool isEditingElapsedTime = false;
  bool isEditingInsulinDuration = false;

  bool showPreviousIntakes = false;
  double? recommendedInsulin;
  String? savedTime;

  @override
  void initState() {
    super.initState();
    _loadSavedValues(); // Load saved values when the widget is created
  }

  // Load saved values from SharedPreferences
  Future<void> _loadSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      icf = prefs.getDouble('icf');
      icr = prefs.getDouble('icr');
      targetInsulinLevel = prefs.getDouble('targetInsulinLevel');
      insulinDuration = prefs.getDouble('insulinDuration');

      icfController.text = icf?.toString() ?? '';
      icrController.text = icr?.toString() ?? '';
      targetInsulinController.text = targetInsulinLevel?.toString() ?? '';
      insulinDurationController.text = insulinDuration?.toString() ?? '';
      recommendedInsulin = prefs.getDouble('recommendedInsulin');
      savedTime = prefs.getString('savedTime');
    });
  }


  // Save input values to SharedPreferences
  Future<void> _saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (icfController.text.isNotEmpty)
      await prefs.setDouble('icf', double.parse(icfController.text));
    if (icrController.text.isNotEmpty)
      await prefs.setDouble('icr', double.parse(icrController.text));
    if (targetInsulinController.text.isNotEmpty)
      await prefs.setDouble(
          'targetInsulinLevel', double.parse(targetInsulinController.text));
    if (insulinDurationController.text.isNotEmpty)
      await prefs.setDouble(
          'insulinDuration', double.parse(insulinDurationController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Recommended Insulin',
          style: TextStyle(
            color: Color(0xFF6373CC),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 20),
            Text(
              'Carbohydrates Intake',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: carbohydratesController,
              decoration: InputDecoration(
                hintText: 'Enter the Carbohydrates intake in the Meal',
                hintStyle: TextStyle(fontSize: 14),
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sugar Levels',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller:
              sugarLevelController, // Added controller for sugarLevel
              decoration: InputDecoration(
                hintText: 'Enter the present Sugar Level',
                hintStyle: TextStyle(fontSize: 14),
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Have you done any activity?',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: activityDropdownValue,
              onChanged: (newValue) {
                setState(() {
                  activityDropdownValue = newValue!;
                });
              },
              items: <String>['No', 'Yes'].map<DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
            ),
            if (activityDropdownValue == 'Yes')
              Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Select Activity Intensity',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            activityIntensity = 'Light';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: activityIntensity == 'Light'
                              ? Color(0xFFF86851)
                              : Color(0xFF6373CC),
                        ),
                        child: Text('Light'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            activityIntensity = 'Medium';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: activityIntensity == 'Medium'
                              ? Color(0xFFF86851)
                              : Color(0xFF6373CC),
                        ),
                        child: Text('Medium'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            activityIntensity = 'Heavy';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: activityIntensity == 'Heavy'
                              ? Color(0xFFF86851)
                              : Color(0xFF6373CC),
                        ),
                        child: Text('Heavy'),
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 20),
            _buildEditableValueField(
              'Insulin Correction Factor (ICF)',
              icfController,
              icf,
              isEditingICF,
                  () {
                setState(() {
                  isEditingICF = !isEditingICF;
                });
              },
            ),
            SizedBox(height: 20),
            _buildEditableValueField(
              'Insulin Carbohydrate Ratio (ICR)',
              icrController,
              icr,
              isEditingICR,
                  () {
                setState(() {
                  isEditingICR = !isEditingICR;
                });
              },
            ),
            SizedBox(height: 20),
            _buildEditableValueField(
              'Target Blood Sugar Level',
              targetInsulinController,
              targetInsulinLevel,
              isEditingTargetInsulin,
                  () {
                setState(() {
                  isEditingTargetInsulin = !isEditingTargetInsulin;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Total Insulin Dose from Previous Bolus',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: totalInsulinDoseController,
              decoration: InputDecoration(
                hintText: 'Enter the Total Insulin Dose from Previous Bolus',
                hintStyle: TextStyle(fontSize: 14),
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Elapsed Time',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: elapsedTimeController,
              decoration: InputDecoration(
                hintText: 'Enter the Elapsed time',
                hintStyle: TextStyle(fontSize: 14),
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _buildEditableValueField(
              'Insulin Duration',
              insulinDurationController,
              insulinDuration,
              isEditingInsulinDuration,
                  () {
                setState(() {
                  isEditingInsulinDuration = !isEditingInsulinDuration;
                });
              },
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final localContext = context; // Store the context

                  await _saveValues(); // Save the input values before navigating

                  try {
                    // Get the necessary values from your state or controllers
                    double carbohydrateCount =
                        double.tryParse(carbohydratesController.text.trim()) ??
                            0.0;
                    double currentSugarLevel =
                        double.tryParse(sugarLevelController.text.trim()) ??
                            0.0;

                    Navigator.push(
                      localContext, // Use the localContext variable here
                      MaterialPageRoute(
                        builder: (context) => RecommendedPage(
                          carbohydrateCount: carbohydrateCount,
                          icr: double.tryParse(icrController.text) ?? 1.0,
                          isActivityYes: activityDropdownValue == 'Yes',
                          activityIntensity: activityIntensity,
                          currentSugarLevel: currentSugarLevel,
                          targetSugarLevel:
                          double.tryParse(targetInsulinController.text) ??
                              100.0,
                          isf: double.tryParse(icfController.text) ?? 0.0,
                          totalInsulinDose: double.tryParse(
                              totalInsulinDoseController.text) ??
                              0.0,
                          elapsedTime:
                          double.tryParse(elapsedTimeController.text) ??
                              0.0,
                          insulinDuration:
                          double.tryParse(insulinDurationController.text) ??
                              1.0,
                        ),
                      ),
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Input Error'),
                          content: Text(
                              'There was an error parsing the input values. Please make sure the input is valid.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    print("Error parsing input: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFF86851),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Recommended Insulin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      showPreviousIntakes = !showPreviousIntakes;
                    });
                  },
                  child: Text(
                    'Show Previous Intakes',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    // Refresh the page when the refresh button is pressed
                    setState(() {
                      _loadSavedValues(); // Reload saved values
                      showPreviousIntakes =
                      false; // Hide the previous intakes section
                    });
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (showPreviousIntakes) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previous Intakes:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('ICF: ${icf ?? "N/A"}'),
                      Text('ICR: ${icr ?? "N/A"}'),
                      Text(
                          'Target Insulin Level: ${targetInsulinLevel ?? "N/A"}'),
                      Text('Insulin Duration: ${insulinDuration ?? "N/A"}'),
                      Text(
                          'Recommended Insulin: ${recommendedInsulin ?? "N/A"}'),
                      Text('Saved Time: ${savedTime ?? "N/A"}'),
                      // You can add more saved values here
                    ],
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildEditableValueField(
      String label,
      TextEditingController controller,
      double? value,
      bool isEditing,
      VoidCallback onEdit,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit),
            ),
          ],
        ),
        SizedBox(height: 10),
        if (isEditing)
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter value',
              hintStyle: TextStyle(fontSize: 14),
              border: UnderlineInputBorder(),
            ),
          )
        else
          Text(
            value != null ? value.toString() : 'Value not entered',
            style: TextStyle(fontSize: 14),
          ),
      ],
    );
  }
}
