class AcademicReport {
  final String? className;
  final String? teacherName;
  final int? totalStudents;
  final int? passedStudents;
  final DateTime? fromDate;
  final DateTime? toDate;


  AcademicReport({
    this.className,
    this.teacherName,
    this.totalStudents,
    this.passedStudents,
    this.fromDate,
    this.toDate
  });

  factory AcademicReport.fromJson(Map<String, dynamic> json) {
    return AcademicReport(
      className: json['className'] as String?,
      teacherName: json['teacherName'] as String?,
      totalStudents: json['totalStudents'] as int?,
      passedStudents: json['passedStudents'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromDate': fromDate?.toIso8601String().split('T').first,
      'toDate': toDate?.toIso8601String().split('T').first,
    };
  }
}
