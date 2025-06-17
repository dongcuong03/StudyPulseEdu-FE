import 'package:study_pulse_edu/models/app/Schedule.dart';

import '../../resources/constains/constants.dart';
import 'Assignment.dart';
import 'Student.dart';
import 'Teacher.dart';

class ClassA{
  final String? id;
  final String? className;
  final String? description;
  Teacher? teacher;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxStudents;
  final double? tuitionFee;
  final ClassStatus? status;
  final List<Schedule>? schedules;
  final List<Student>? students;
  final List<Assignment>? assignments;

  ClassA({
    this.id,
    this.className,
    this.description,
    this.teacher,
    this.startDate,
    this.endDate,
    this.maxStudents,
    this.tuitionFee,
    this.status,
    this.schedules,
    this.students,
    this.assignments,
  });

  factory ClassA.fromJson(Map<String, dynamic> json) {
    return ClassA(
      id: json['id'] as String?,
      className: json['className'] as String?,
      description: json['description'] as String?,
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      maxStudents: json['maxStudent'] as int?,
      tuitionFee: json['tuitionFee'] != null
          ? (json['tuitionFee'] as num).toDouble()
          : null,
      status: ClassStatus.fromString(json['status']),
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((s) => Schedule.fromJson(s))
          .toList(),
      students: (json['students'] as List<dynamic>?)?.map((s) => Student.fromJson(s)).toList(),
      assignments: (json['assignments'] as List<dynamic>?)
          ?.map((s) => Assignment.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': className,
      'description': description,
      'teacher': teacher?.toJson(),
      'startDate': startDate?.toIso8601String().split('T').first,
      'endDate': endDate?.toIso8601String().split('T').first,
      'maxStudent': maxStudents,
      'tuitionFee': tuitionFee,
      'status': status?.toJson(),
      'schedules': schedules?.map((s) => s.toJson()).toList(),
      'students': students?.map((s) => s.toJson()).toList(),
      'assignments': assignments?.map((a) => a.toJson()).toList(),

    };
  }
}