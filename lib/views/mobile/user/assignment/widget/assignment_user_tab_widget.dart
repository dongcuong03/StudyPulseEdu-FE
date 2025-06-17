import 'package:flutter/material.dart';
import 'package:study_pulse_edu/models/app/Assignment.dart';

import 'assignment_user_card.widget.dart';

enum AssignmentTabType {
  all,
  notSubmitted,
  submitted,
  overdue,
}


class AssignmentTab extends StatelessWidget {
  final List<Assignment> assignments;
  final String? studentId;
  final String? studentName;
  final String? studentCode;
  final VoidCallback onSubmitted;

  const AssignmentTab({
    super.key,
    required this.assignments,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const Center(child: Text(""));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return AssignmentCard(
          assignment: assignment,
          studentId: studentId,
          studentName: studentName,
          studentCode: studentCode,
          onSubmitted: onSubmitted,
        );
      },
    );
  }
}
