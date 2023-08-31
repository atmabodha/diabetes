import 'dart:io';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:diabetes_ms/Screens/OnBoarding/SelectYourDoctor.dart';
import 'package:diabetes_ms/Screens/Patient/HomeScreenP.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePic extends StatefulWidget {
  static String id = "ProfilePic";
  const ProfilePic({Key? key}) : super(key: key);

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  late SharedPreferences prefs;
  late String profilePicturePath;


  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    profilePicturePath = prefs.getString('profilePicturePath') ?? '';
    if (profilePicturePath.isNotEmpty) {
      context.read<UserProvider>().setImageFile(File(profilePicturePath));
      setState(() {});
    }
  }

  // Function to pick and set profile picture
  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      String imagePath = pickedImage.path;
      File imageFile = File(imagePath);

      await imageFile.writeAsBytes(await pickedImage.readAsBytes());
      await prefs.setString('profilePicturePath', imagePath);

      profilePicturePath = (await prefs.getString('profilePicturePath'))!;

      context.read<UserProvider>().setImageFile(File(profilePicturePath));

      setState(() {
        profilePicturePath = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isProfilePictureSelected = context.watch<UserProvider>().imageFile != null;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Add a Profile Picture',
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
                            backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
                          );
                        } else {
                          return CircleAvatar(
                              radius: 150,
                              backgroundImage: FileImage(imageProvider.imageFile!) as ImageProvider);
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
              onPressed: isProfilePictureSelected
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectYourDoctor(),
                  ),
                );
              }
              : null,
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
              child: const Text('Set Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
