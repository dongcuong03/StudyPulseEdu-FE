import 'ClassStudentCountResponseDto.dart';
import 'TeacherClassCountResponseDto.dart';

class DashboardResponseDto {
  final int numberOfAccount;
  final int numberOfStudent;
  final int numberOfTeacher;
  final int numberOfClass;
  final List<TeacherClassCountResponseDto> teacherClassCounts;
  final List<ClassStudentCountResponseDto> classStudentCounts;

  DashboardResponseDto({
    required this.numberOfAccount,
    required this.numberOfStudent,
    required this.numberOfTeacher,
    required this.numberOfClass,
    required this.teacherClassCounts,
    required this.classStudentCounts,
  });

  factory DashboardResponseDto.fromJson(Map<String, dynamic> json) {
    return DashboardResponseDto(
      numberOfAccount: json['numberOfAccount'],
      numberOfStudent: json['numberOfStudent'],
      numberOfTeacher: json['numberOfTeacher'],
      numberOfClass: json['numberOfClass'],
      teacherClassCounts: (json['teacherClassCounts'] as List)
          .map((e) => TeacherClassCountResponseDto.fromJson(e))
          .toList(),
      classStudentCounts: (json['classStudentCounts'] as List)
          .map((e) => ClassStudentCountResponseDto.fromJson(e))
          .toList(),
    );
  }
}
