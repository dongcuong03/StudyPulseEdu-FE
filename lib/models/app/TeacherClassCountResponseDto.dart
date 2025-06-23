class TeacherClassCountResponseDto {
  final String teacherId;
  final String teacherName;
  final int classCount;

  TeacherClassCountResponseDto({
    required this.teacherId,
    required this.teacherName,
    required this.classCount,
  });

  factory TeacherClassCountResponseDto.fromJson(Map<String, dynamic> json) {
    return TeacherClassCountResponseDto(
      teacherId: json['teacherId'],
      teacherName: json['teacherName'],
      classCount: json['classCount'],
    );
  }
}
