import 'package:study_pulse_edu/models/app/ClassA.dart';
import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';

class AcademicResult{
  final Student? student;
  final ClassA? classA;
  final double? testScore;
  final double? assignmentScore;
  final double? attendanceScore;
  final double? summaryScore;
  final AcademicResultStatus? result;
  String? note;

  AcademicResult({
    required this.student,
    required this.classA,
    required this.testScore,
    required this.assignmentScore,
    required this.attendanceScore,
    required this.summaryScore,
    required this.result,
    required this.note
  });

  factory AcademicResult.fromJson(Map<String, dynamic> json) {
    return AcademicResult(
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
      classA: json['classA'] != null ? ClassA.fromJson(json['classA']) : null,
      testScore: (json['testScore'] ?? 0).toDouble(),
      assignmentScore: (json['assignmentScore'] ?? 0).toDouble(),
      attendanceScore: (json['attendanceScore'] ?? 0).toDouble(),
      summaryScore: (json['summaryScore'] ?? 0).toDouble(),
      result: json['result'] != null ? AcademicResultStatus.fromString(json['result'] as String) : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student?.toJson(),
      'classA': classA?.toJson(),
      'testScore': testScore,
      'assignmentScore': assignmentScore,
      'attendanceScore': attendanceScore,
      'summaryScore': summaryScore,
      'result': result?.toJson(),
      'note': note,
    };
  }

}