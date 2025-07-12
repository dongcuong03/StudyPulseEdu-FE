import '../../resources/constains/constants.dart';
import 'ClassRoom.dart';
import 'Parent.dart';

class Student {
  final String? id;
  final String? studentCode;
  final String? fullName;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final EnrollmentStatus? enrollmentStatus;

  const Student({
    this.id,
    this.studentCode,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.enrollmentStatus
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String?,
      studentCode: json['studentCode'] as String?,
      fullName: json['fullName'] as String?,
      gender: json['gender'] != null ? Gender.fromString(json['gender'] as String) : null,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      address: json['address'] as String?,
      enrollmentStatus: json['enrollmentStatus'] != null
          ? EnrollmentStatus.fromString(json['enrollmentStatus'] as String)
          : null,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentCode': studentCode,
      'fullName': fullName,
      'gender': gender?.toJson(),
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'enrollmentStatus': enrollmentStatus?.toJson(),
    };
  }
  @override
  String toString() {
    return 'Student(id: $id, studentCode: $studentCode, fullName: $fullName, gender: $gender, dateOfBirth: $dateOfBirth, address: $address)';
  }

}
