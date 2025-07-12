import 'package:study_pulse_edu/models/app/ClassRoom.dart';
import 'package:study_pulse_edu/models/app/Student.dart';

class Score{
  final String? id;
  final Student? student;
  final ClassRoom? classRoom;
  final double? scoreTest1;
  final double? scoreTest2;
  final double? scoreMidterm;
  final double? scoreFinal;

  Score({
    this.id,
    this.student,
    this.classRoom,
    this.scoreTest1,
    this.scoreTest2,
    this.scoreMidterm,
    this.scoreFinal,
  });

  factory Score.fromJson(Map<String, dynamic> json) => Score(
    id: json['id'],
    student:  json['student'] != null ? Student.fromJson(json['student']) : null,
    classRoom:  json['classRoom'] != null ? ClassRoom.fromJson(json['classRoom']) : null,
    scoreTest1: (json['scoreTest1'] as num?)?.toDouble(),
    scoreTest2: (json['scoreTest2'] as num?)?.toDouble(),
    scoreMidterm: (json['scoreMidterm'] as num?)?.toDouble(),
    scoreFinal: (json['scoreFinal'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'studentId': student?.id,
    'classId': classRoom?.id,
    'scoreTest1': scoreTest1,
    'scoreTest2': scoreTest2,
    'scoreMidterm': scoreMidterm,
    'scoreFinal': scoreFinal,
  };
}
