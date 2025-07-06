import 'package:study_pulse_edu/models/app/Submission.dart';

import 'ClassA.dart';
import 'Teacher.dart';

class Assignment{
  final String? id;
  final ClassA? classA;
  final String? title;
  final String? description;
  final DateTime? dueDate;
  final String? dueTime;
  final String? attachmentUrl;
  final DateTime? createdAt;
  final List<Submission>? submissions;
  final int? totalStudentOfClass;
  Assignment({
    this.id,
    this.classA,
    this.title,
    this.description,
    this.dueDate,
    this.dueTime,
    this.attachmentUrl,
    this.createdAt,
    this.submissions,
    this.totalStudentOfClass
  });
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String?,
      classA: ClassA(
        id: json['classId'],
        className: json['className'],
        teacher: Teacher(
          fullName:  json['nameTeacher'],
          avatarUrl: json['avatarUrl'],
        )
      ),
      title: json['title'] as String?,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      dueTime: json['dueTime'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      submissions: (json['submissions'] as List<dynamic>?)
          ?.map((s) => Submission.fromJson(s))
          .toList(),
      totalStudentOfClass: json['totalStudentOfClass'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classA': classA?.toJson(),
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String().split('T').first,
      'dueTime': dueTime,
      'attachmentUrl': attachmentUrl,
      'createdAt':createdAt,
      'submissions': submissions?.map((s) => s.toJson()).toList(),
      'totalStudentOfClass': totalStudentOfClass,
    };
  }
}