import '../../resources/constains/constants.dart';
import 'account.dart';

class Teacher {
  final String? id;
  final String? fullName;
  final String? avatarUrl;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? educationLevel;
  final String? specialization;
  final String? introduction;

  const Teacher({
    this.id,
    this.fullName,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.educationLevel,
    this.specialization,
    this.introduction,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String?,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      gender: json['gender'] != null ? Gender.fromString(json['gender'] as String) : null,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      address: json['address'] as String?,
      educationLevel: json['educationLevel'] as String?,
      specialization: json['specialization'] as String?,
      introduction: json['introduction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'gender': gender?.toJson(),
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'educationLevel': educationLevel,
      'specialization': specialization,
      'introduction': introduction,
    };
  }
  @override
  String toString() {
    return 'Teacher(id: $id, fullName: $fullName, avatarUrl: $avatarUrl, gender: $gender, dateOfBirth: $dateOfBirth, address: $address, educationLevel: $educationLevel, specialization: $specialization, introduction: $introduction)';
  }

}
