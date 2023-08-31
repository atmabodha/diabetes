import 'package:diabetes_ms/Screens/Patient/ChangeProfilePic.dart';
import 'package:diabetes_ms/Screens/OnBoarding/ProfilePic.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Providers/UserInfo.dart';
import 'ChangeDoctor.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                      icon: Icon(Icons.arrow_back,color:Color(0xff6373CC),size: 30,),
                      onPressed: () {
                        // Pop the current context to navigate back when the back icon is pressed.
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      "My Profile",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: Color(0xff6373CC),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChnageProfilePic(),
                      ),
                    );
                  },
                  child: Consumer<UserProvider>(
                    builder: (context, imageProvider, _) {
                      if (imageProvider.imageFile == null) {
                        return const CircleAvatar(
                          radius: 150,
                          backgroundImage: AssetImage(
                              'assets/images/default_profile_pic.png'),
                        );
                      } else {
                        return CircleAvatar(
                            radius: 150,
                            backgroundImage:
                            FileImage(imageProvider.imageFile!)
                            as ImageProvider);
                      }
                    },
                  ),
                ),
                SizedBox(height: 20,),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Container(
                      padding: EdgeInsets.zero,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${userProvider.name}",
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
                SizedBox(height: 15,),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    Color textColor;
                    String statusText;

                    // Determine the text color and status text based on user's status
                    switch (userProvider.status) {
                      case 0:
                        textColor = Colors.yellow; // Pending - Yellow color
                        statusText = "Pending";
                        break;
                      case 1:
                        textColor = Colors.green; // Approved - Green color
                        statusText = "Approved";
                        break;
                      case 2:
                        textColor = Colors.red; // Rejected - Red color
                        statusText = "Rejected";
                        break;
                      default:
                        textColor = Colors.yellow; // Default color
                        statusText = "Pending";
                    }

                    return Container(
                      padding: EdgeInsets.zero,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Text("Status: ",textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              statusText,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 40,),
                ElevatedButton(
                  onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeYourDoctor(),
                        ),
                      );
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change Your Doctor',
                          style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontSize: 16,
                              )),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
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
