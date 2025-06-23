import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/models/app/Parent.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
import '../../resources/constains/constants.dart';

class TuitionFee {
  final Student? student;
  final Parent? parent;
  final ClassA? classA;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final TuitionStatus? status;
  final double? totalTuitionFee;
  final double? unpaidTuitionFee;

  TuitionFee({
    this.student,
    this.parent,
    this.classA,
    this.dueDate,
    this.paidAt,
    this.status,
    this.totalTuitionFee,
    this.unpaidTuitionFee
  });

  factory TuitionFee.fromJson(Map<String, dynamic> json) {
    return TuitionFee(
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
      parent: json['parent'] != null ? Parent.fromJson(json['parent']) : null,
      classA: json['classA'] != null ? ClassA.fromJson(json['classA']) : null,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      status: json['status'] != null ? TuitionStatus.fromString(json['status']) : null,
      totalTuitionFee: (json['totalTuitionFee'] as num?)?.toDouble(),
      unpaidTuitionFee: (json['unpaidTuitionFee'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student?.toJson(),
      'parent': parent?.toJson(),
      'classA': classA?.toJson(),
      'dueDate': dueDate?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'status': status?.toJson(),
      'totalTuitionFee': totalTuitionFee,
      'unpaidTuitionFee': unpaidTuitionFee,
    };
  }
}
