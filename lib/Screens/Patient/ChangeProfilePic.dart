import 'dart:convert';
import 'dart:io';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:diabetes_ms/Screens/OnBoarding/SelectYourDoctor.dart';
import 'package:diabetes_ms/Screens/Patient/HomeScreenP.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChnageProfilePic extends StatefulWidget {
  static String id = "ProfilePic";
  const ChnageProfilePic({Key? key}) : super(key: key);

  @override
  State<ChnageProfilePic> createState() => _ChnageProfilePicState();
}

class _ChnageProfilePicState extends State<ChnageProfilePic> {
  late SharedPreferences prefs;
  late String profilePicturePath;

  @override
  void initState() {
    super.initState();
  }

  // Update profile picture by sending image to the server
  Future<void> updateProfilePicture(File imageFile, String phoneNumber) async {
    try {
      final url = 'http://10.0.2.2:5000/update_profile'; // Replace with your API endpoint
      String base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        // Profile picture updated successfully
        print('Profile picture updated successfully');
        // You can add further actions or display a success message here if needed
      } else {
        // Failed to update profile picture
        print('Failed to update profile picture: ${response.body}');
        // You can display an error message here if needed
      }
    } catch (e) {
      // Error occurred during API call
      print('Error occurred during API call: $e');
      // You can display an error message here if needed
    }
  }

  // Pick profile picture from gallery
  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      String imagePath = pickedImage.path;
      File imageFile = File(imagePath);

      await imageFile.writeAsBytes(await pickedImage.readAsBytes());
      context.read<UserProvider>().setImageFile(File(imagePath));

      setState(() {
        profilePicturePath = imagePath;
      });

      String? phoneNumber = context.read<UserProvider>().phoneNumber;
      await updateProfilePicture(imageFile, phoneNumber!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Change Profile Picture',
              style: GoogleFonts.inter(
                color: Color(0xff6373CC),
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            SizedBox(
              height: 70,
            ),
            Center(
              child: Stack(
                children: [
                  Hero(
                    tag: 'profilePic',
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
                  Positioned(
                    bottom: 0,
                    right: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff6373CC),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _pickProfilePicture();
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickProfilePicture,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
              ),
              child:Text(
                'Change Picture',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreenP(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(MediaQuery.of(context).size.width * 0.75, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Color(0xff6373CC),
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
