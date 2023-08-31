import 'dart:io';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {

  String? _name = '';
  String? _phoneNumber;
  String? _dateOfBirth;
  String? _gender;
  String? _city;
  String? _medicalCondition;
  String? _familyHistory;
  String? _bloodGroup;
  String? _doctorid;
  int? _status;
  File? _imageFile;
  double? _log = 0;


  String? get name => _name;
  String? get phoneNumber => _phoneNumber;
  String? get dateOfBirth => _dateOfBirth;
  String? get city => _city;
  String? get gender => _gender;
  String? get medicalCondition => _medicalCondition;
  String? get familyHistory => _familyHistory;
  String? get bloodGroup => _bloodGroup;
  String? get doctorid => _doctorid;
  int? get status => _status;
  File? get imageFile => _imageFile;
  double? get log => _log;


  void setImageFile(File file) {
    _imageFile = file;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void setDateOfBirth(String dateOfBirth) {
    _dateOfBirth = dateOfBirth;
    notifyListeners();
  }

  void setCity(String city) {
    _city = city;
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setMedicalCondition(String medicalCondition) {
    _medicalCondition = medicalCondition;
    notifyListeners();
  }

  void setFamilyHistory(String familyHistory) {
    _familyHistory = familyHistory;
    notifyListeners();
  }

  void setBloodGroup(String bloodGroup) {
    _bloodGroup = bloodGroup;
    notifyListeners();
  }

  void setDoctorid(String doctorid) {
    _doctorid = doctorid;
    notifyListeners();
  }

  void setStatus(int status) {
    _status = status;
    notifyListeners();
  }

  void setLog(double log) {
    _log = log;
    notifyListeners();
  }

}
