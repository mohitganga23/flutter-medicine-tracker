import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/navigation_helper.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final ProfileService _profileService = ProfileService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;

  String? _selectedGender;

  File? _profileImage;
  String? _profilePhotoUrl;

  List<Map<String, dynamic>> _familyMembers = [];
  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _familyAgeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile['name']);
    _ageController = TextEditingController(
      text: widget.userProfile['age'] == "-" ? "" : widget.userProfile['age'],
    );

    _selectedGender = widget.userProfile['gender'] != "-"
        ? widget.userProfile['gender']
        : "Male";
    _profilePhotoUrl = widget.userProfile['profile_photo_url'];

    _familyMembers = widget.userProfile['family_members'] != null
        ? List<Map<String, dynamic>>.from(widget.userProfile['family_members'])
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _familyNameController.dispose();
    _familyAgeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      await _profileService.updateUserProfile(
        ctx: context,
        name: _nameController.text.trim(),
        age: _ageController.text.trim(),
        gender: _selectedGender.toString(),
        profilePhotoUrl:
        _profilePhotoUrl != null ? _profilePhotoUrl.toString() : "-",
        profileImage: _profileImage,
        familyMembers: _familyMembers,
      );

      if (!mounted) return;
      NavigationHelper.pop(context);
    }
  }

  void _addFamilyMember() {
    if (_familyNameController.text.isNotEmpty &&
        _familyAgeController.text.isNotEmpty) {
      setState(() {
        _familyMembers.add({
          'name': _familyNameController.text.trim(),
          'age': _familyAgeController.text.trim(),
        });
        _familyNameController.clear();
        _familyAgeController.clear();
      });
    }
  }

  void _removeFamilyMember(Map<String, dynamic> member) {
    setState(() {
      _familyMembers.remove(member);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurpleAccent,
                  child: _profileImage != null
                      ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                      : _profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      _profilePhotoUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female', 'Other']
                    .map(
                      (gender) => DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              const Text(
                'Family Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _familyMembers.length,
                itemBuilder: (context, index) {
                  final member = _familyMembers[index];
                  return ListTile(
                    title: Text(member['name']),
                    subtitle: Text('Age: ${member['age']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeFamilyMember(member),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _familyNameController,
                decoration: const InputDecoration(
                  labelText: 'Family Member Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _familyAgeController,
                decoration: const InputDecoration(
                  labelText: 'Family Member Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addFamilyMember,
                child: const Text('Add Family Member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
