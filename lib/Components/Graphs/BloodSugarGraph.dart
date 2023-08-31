import 'dart:convert';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../ColorBlockDialog.dart';
import '../Log/BloodSugarLogs.dart';

class BloodSugarGraph extends StatefulWidget {

  final String patientNumber; // Using the "?" makes it optional
  BloodSugarGraph({required this.patientNumber});

  @override
  _BloodSugarGraphState createState() => _BloodSugarGraphState();
}

class _BloodSugarGraphState extends State<BloodSugarGraph> {
  List<Map<String, dynamic>> bloodSugarData = [];

  @override
  void initState() {
    super.initState();
    fetchData(widget.patientNumber);
  }

  Future<void> fetchData(phoneNumber) async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/blood_sugar_records/$phoneNumber'));
    if (response.statusCode == 200) {
      setState(() {
        bloodSugarData =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        print(bloodSugarData);
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff6373CC)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Blood Sugar Statistics",
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6373CC),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ColorBlocksDialog();
                },
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: bloodSugarData.isNotEmpty
              ? buildBloodSugarGraph()
              : const CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff6373CC),
        onPressed: () {
          // Show the dialog box with three blocks of colors and text
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BloodSugarLog(patientNumber: widget.patientNumber,),
            ),
          );
        },
        child: const Icon(Icons.book),
      ),
    );
  }

  Widget buildBloodSugarGraph() {
    List<ChartData> chartData = [];
    for (var data in bloodSugarData) {
      var bloodSugar = data['blood_sugar'];
      var date = DateTime.parse(data['date']);
      var timeString = data['time'];
      var meal_time = data['meal_type'];
      print(timeString);
      List<String> timeComponents = timeString.split(':');
      int hour = int.parse(timeComponents[0]);
      int minute = int.parse(timeComponents[1]);

      var combinedDateTime = DateTime(date.year, date.month, date.day, hour, minute);
      chartData.add(ChartData(combinedDateTime, bloodSugar,meal_time));
    }

    chartData.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return SfCartesianChart(
      plotAreaBorderColor: const Color(0xffF2F2F2),
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 0),
        majorGridLines: const MajorGridLines(width: 0), // Hide major grid lines
        minorGridLines: const MinorGridLines(width: 0),
        visibleMinimum: chartData.length >= 5 ? chartData.length - 5 : 0,
        majorTickLines: const MajorTickLines(size: 0), // Hide major tick lines
        edgeLabelPlacement:
            EdgeLabelPlacement.shift, // Shift the labels to avoid overlap
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: "Blood Sugar",textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        ),),
        majorGridLines: const MajorGridLines(width: 0), // Hide major grid lines
        minorGridLines: const MinorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0), // Hide major tick lines
        edgeLabelPlacement:
            EdgeLabelPlacement.shift, // Shift the labels to avoid overlap
        axisLine: const AxisLine(width: 2,color: Color(0xff6373CC)),
        minimum: 0,
        maximum:
            250, // Set the max Y value as needed based on your blood sugar data
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enableDoubleTapZooming: true,
        enablePinching: true,
        enableSelectionZooming: true,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
      ),
      legend: const Legend(
        // Add the Legend widget here
        isVisible: true,
        position: LegendPosition.bottom,
      ),
      series: <LineSeries<ChartData, DateTime>>[
        LineSeries<ChartData, DateTime>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.dateTime,
          yValueMapper: (ChartData data, _) => data.bloodSugar,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.auto,
            builder: (dynamic data, dynamic point, dynamic series,
                int dataIndex, int pointIndex) {
              if (data is ChartData) {
                // Format the date as "dd/MM/yyyy"
                var dateFormatter = DateFormat('dd/MM/yyyy');
                String formattedDate = dateFormatter.format(data.dateTime);

                // Format the time as "HH:mm"
                var timeFormatter = DateFormat('hh:mm a');
                String formattedTime = timeFormatter.format(data.dateTime);

                final String customLabel = '$formattedDate \n $formattedTime \n ${data.bloodSugar.toInt()}';

                var Boxcolor = Colors.black87;
                if(data.meal_time == 'Before'){
                  Boxcolor = Colors.teal;
                } else if (data.meal_time == 'After'){
                  Boxcolor = Colors.deepPurpleAccent;
                } else{
                  Boxcolor = Colors.lightBlue;
                }

                return Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Boxcolor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    customLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
          markerSettings: const MarkerSettings(
            isVisible: true,
            // You can customize the marker shape, size, and color here
            shape: DataMarkerType.circle,
            width: 8,
            height: 8,
            color: Color(0xffF86851),
            borderColor: Colors.white,
            borderWidth: 2,
          ),
        ),
      ],
    );
  }
}

class ChartData {
  final DateTime dateTime;
  final double bloodSugar;
  final meal_time;

  ChartData(this.dateTime, this.bloodSugar,this.meal_time);
}
