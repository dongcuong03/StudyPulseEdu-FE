class Submission{
  final String? id;
  final String? assignmentId;
  final String? studentId;
  final String? fileUrl;
  final String? description;
  final double? score;
  final String? feedback;
  final DateTime? createdAt;
  Submission({
    this.id,
    this.assignmentId,
    this.studentId,
    this.fileUrl,
    this.description,
    this.score,
    this.feedback,
    this.createdAt
  });
  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as String?,
      assignmentId: json['assignmentId'] as String?,
      studentId: json['studentId'] as String?,
      fileUrl: json['fileUrl'] as String?,
      description: json['description'] as String?,
      score: json['score'] != null
          ? (json['score'] as num).toDouble()
          : null,
      feedback: json['feedback'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  // Từ object sang JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'fileUrl': fileUrl,
      'description': description,
      'score': score,
      'feedback': feedback,
      'createdAt':createdAt
    };
  }
}