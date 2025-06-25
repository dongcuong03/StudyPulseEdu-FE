class TuitionReport {
  final String? classId;
  final String? className;
  final double? totalTuition;
  final double? paidAmount;
  final double? unpaidAmount;
  final DateTime? fromDate;
  final DateTime? toDate;

  TuitionReport({
    this.classId,
    this.className,
    this.totalTuition,
    this.paidAmount,
    this.unpaidAmount,
    this.fromDate,
    this.toDate
  });

  factory TuitionReport.fromJson(Map<String, dynamic> json) {
    return TuitionReport(
      classId: json['classId'] as String?,
      className: json['className'] as String?,
      totalTuition: (json['totalTuition'] as num?)?.toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      unpaidAmount: (json['unpaidAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromDate': fromDate?.toIso8601String().split('T').first,
      'toDate': toDate?.toIso8601String().split('T').first,
    };
  }
}
