import 'package:study_pulse_edu/models/app/Submission.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';

import 'ClassRoom.dart';
import 'Student.dart';
import 'Teacher.dart';

class Attendance{
  final String? id;
  final ClassRoom? classRoom;
  final Student? student;
  final Teacher? teacher;
  final AttendanceStatus? status;
  final DateTime? attendanceDatetime;
  final String? note;
  final bool? notified;
  Attendance({
    this.id,
    this.classRoom,
    this.student,
    this.teacher,
    this.status,
    this.attendanceDatetime,
    this.note,
    this.notified,
  });
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String?,
      classRoom: ClassRoom(
          id: json['classId'],
          className: json['className'],
          teacher: Teacher(
            id:  json['teacherId'],
            fullName:  json['nameTeacher'],
          )
      ),
      teacher: Teacher(
        id:  json['teacherId'],
        fullName:  json['nameTeacher'],
      ),
      student: Student(
        id: json['studentId'],
        studentCode: json['studentCode'],
        fullName:  json['studentName']
      ),
      attendanceDatetime: json['attendanceDatetime'] != null ? DateTime.parse(json['attendanceDatetime']) : null,
      status: json['status'] != null ? AttendanceStatus.fromString(json['status'] as String) : null,
      note: json['note'],
        notified : json['notified']
    );
  }

  // Từ object sang JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classRoom': classRoom?.toJson(),
      'teacher': teacher?.toJson(),
      'student': student?.toJson(),
      'status': status?.toJson(),
      'attendanceDatetime': attendanceDatetime?.toIso8601String(),
      'note': note,
      'notified': notified
    };
  }
}