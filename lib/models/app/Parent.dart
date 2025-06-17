import 'Account.dart';
import 'Student.dart';

class Parent {
  final String? id;
  final String? fullName;
  final String? verificationCode;
  final String? relationship;
  final List<Student>? students;

  const Parent({
    this.id,
    this.fullName,
    this.verificationCode,
    this.relationship,
    this.students,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'] as String?,
      fullName: json['fullName'] as String?,
      verificationCode: json['verificationCode'] as String?,
      relationship: json['relationship'] as String?,
      students: (json['students'] as List<dynamic>?)
          ?.map((s) => Student.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'verificationCode': verificationCode,
      'relationship': relationship,
      'students': students?.map((s) => s.toJson()).toList(),
    };
  }
  @override
  String toString() {
    return 'Parent(id: $id, fullName: $fullName, verificationCode: $verificationCode, relationship: $relationship, students: $students)';
  }

}
