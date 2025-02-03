import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
          appBar: AppBar(title: const Text('Add Medication')),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: medicationProvider.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Member',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: medicationProvider.selectedMember,
                      alignment: AlignmentDirectional.centerStart,
                      decoration: const InputDecoration(
                        hintText: 'Select Member',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.person_2_outlined),
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
                    const SizedBox(height: 20),

                    // Medication Name Field
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        "Medication",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      controller: medicationProvider.medicationNameController,
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

                    // Attach Note
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 5),
                      child: Text(
                        "Attach a Note",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      controller: medicationProvider.attachNoteController,
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

                    // Dosage
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 5),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_outlined),
                          const SizedBox(width: 10),
                          const Text(
                            "Dosage",
                            style: TextStyle(fontSize: 18),
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
                    const SizedBox(height: 20),
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
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 60),
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
          ),
        );
      },
    );
  }
}
