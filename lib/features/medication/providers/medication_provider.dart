import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/ui_helper.dart';
import '../services/medication_service.dart';

class MedicationProvider with ChangeNotifier {
  MedicationService medicationService = MedicationService();

  final FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  get formKey => _formKey;

  final medicationNameController = TextEditingController();
  final attachNoteController = TextEditingController();

  final List<TimeOfDay> _dosageTiming = [];

  List<TimeOfDay> get dosageTiming => _dosageTiming;

  List<Map<String, dynamic>> _familyMembers = [];

  List<Map<String, dynamic>> get familyMembers => _familyMembers;

  String? _selectedMember = "Self";

  String? get selectedMember => _selectedMember;

  bool _isUploading = false;

  bool get isUploading => _isUploading;

  void toggleLoading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  setSelectedMember(String value) {
    _selectedMember = value;
    notifyListeners();
  }

  setDosageTime(BuildContext ctx) async {
    TimeOfDay? time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      _dosageTiming.add(time);
    }

    notifyListeners();
  }

  removeDosageTime(int idx) {
    _dosageTiming.removeAt(idx);
    notifyListeners();
  }

  Future<void> fetchFamilyMembers(BuildContext ctx) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('user_profile')
          .doc(auth.currentUser!.email.toString())
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['family_members'] != null) {
          _familyMembers = List<Map<String, dynamic>>.from(
            data['family_members'] as List,
          );
        }
      }
    } catch (e) {
      if (!ctx.mounted) return;
      showCustomSnackBar(
        ctx,
        'Failed to fetch family members.',
        Colors.red,
      );
    }

    notifyListeners();
  }

  addMedication(BuildContext ctx) async {
    if (_formKey.currentState!.validate()) {
      if (dosageTiming.isEmpty) {
        showCustomSnackBar(
          ctx,
          "Please select dosage timing...",
          Colors.red,
        );
      } else {
        toggleLoading();

        await medicationService.addAndScheduleMedication(
          ctx,
          _selectedMember.toString(),
          medicationNameController.text,
          attachNoteController.text,
          _dosageTiming,
        );

        toggleLoading();
      }
    }
  }

  resetProvider() {
    medicationNameController.clear();
    attachNoteController.clear();
    _dosageTiming.clear();
    _familyMembers.clear();
    _selectedMember = "Self";
    _isUploading = false;
  }

  @override
  void dispose() {
    resetProvider();
    super.dispose();
  }
}
