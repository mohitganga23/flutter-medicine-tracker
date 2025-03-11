import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import '../providers/medication_provider.dart';

class AddMedicationForm extends StatefulWidget {
  const AddMedicationForm({super.key});

  @override
  State<AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<AddMedicationForm> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, medicationProvider, child) {
        // Fetch Family Members
        medicationProvider.fetchFamilyMembers(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Add Medication',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: medicationProvider.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Member',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  SizedBox(height: 5.h),
                  DropdownButtonFormField<String>(
                    value: medicationProvider.selectedMember,
                    alignment: AlignmentDirectional.centerStart,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: GoogleFonts.wixMadeforDisplay().fontFamily,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Select Member',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.person_2_outlined),
                      contentPadding: EdgeInsets.fromLTRB(12, 18, 12, 18),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: "Self",
                        child: Text("Self"),
                      ),
                      ...medicationProvider.familyMembers.map(
                        (member) => DropdownMenuItem(
                          value: member['name'],
                          child: Text(member['name']),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      medicationProvider.setSelectedMember(value!);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a member';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),

                  // Medication Name Field
                  Text(
                    "Medication",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: medicationProvider.medicationNameController,
                    style: TextStyle(fontSize: 18.sp),
                    decoration: const InputDecoration(
                      hintText: 'Enter...',
                      prefixIcon: Icon(Bootstrap.capsule),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.deepPurple,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medication name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),

                  // Attach Note
                  Text(
                    "Attach a Note",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: medicationProvider.attachNoteController,
                    style: TextStyle(fontSize: 18.sp),
                    decoration: const InputDecoration(
                      hintText: 'Enter...',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.deepPurple,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Dosage
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined),
                      SizedBox(width: 5.w),
                      Text(
                        "Dosage",
                        style: TextStyle(fontSize: 15.sp),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => medicationProvider.setDosageTime(
                          context,
                        ),
                        label: const Text('Add'),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  if (medicationProvider.dosageTiming.isNotEmpty) ...[
                    Wrap(
                      spacing: 5,
                      children: List.generate(
                        medicationProvider.dosageTiming.length,
                        (index) {
                          return Chip(
                            label: Text(
                              medicationProvider.dosageTiming[index]
                                  .format(context),
                            ),
                            onDeleted: () =>
                                medicationProvider.removeDosageTime(
                              index,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Submit Button
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () => medicationProvider.addMedication(
                      context,
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(
                        MediaQuery.of(context).size.width,
                        45.h,
                      ),
                    ),
                    child: medicationProvider.isUploading
                        ? const SpinKitThreeBounce(
                            color: Colors.white,
                            size: 24,
                          )
                        : const Text('Add Medication'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
