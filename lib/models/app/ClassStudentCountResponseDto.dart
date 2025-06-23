class ClassStudentCountResponseDto {
  final String classId;
  final String className;
  final int studentCount;

  ClassStudentCountResponseDto({
    required this.classId,
    required this.className,
    required this.studentCount,
  });

  factory ClassStudentCountResponseDto.fromJson(Map<String, dynamic> json) {
    return ClassStudentCountResponseDto(
      classId: json['classId'],
      className: json['className'],
      studentCount: json['studentCount'],
    );
  }
}
