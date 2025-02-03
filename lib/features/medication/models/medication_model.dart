import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String member;
  final String medicationName;
  final String notes;
  final DateTime createdAt;
  final List<Dosage> dosages;

  Medication({
    required this.member,
    required this.medicationName,
    required this.notes,
    required this.createdAt,
    required this.dosages,
  });

  // Convert Medication to Map, including nested dosages
  Map<String, dynamic> toMap() {
    return {
      'member': member,
      'medication_name': medicationName,
      'notes': notes,
      'created_at': createdAt,
      'dosages': dosages.map((dosage) => dosage.toMap()).toList(),
    };
  }

  // Create Medication from Map
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      member: map['member'] ?? '',
      medicationName: map['medication_name'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      dosages: (map['dosages'] as List<dynamic>)
          .map((dosageMap) => Dosage.fromMap(dosageMap))
          .toList(),
    );
  }
}

class Dosage {
  final String time;
  final String status;
  final int notificationId;

  Dosage({
    required this.time,
    required this.status,
    required this.notificationId,
  });

  // Convert Dosage to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'status': status,
      'notification_id': notificationId,
    };
  }

  // Create Dosage from Map
  factory Dosage.fromMap(Map<String, dynamic> map) {
    return Dosage(
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      notificationId: map['notification_id'] ?? 0,
    );
  }
}
