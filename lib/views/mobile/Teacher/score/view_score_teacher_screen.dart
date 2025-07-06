import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_pulse_edu/models/app/Account.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/viewmodels/mobile/score_mobile_teacher_view_model.dart';

class ViewScoreTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;
  final ClassA? classA;

  const ViewScoreTeacherScreen({
    super.key,
    required this.account,
    required this.classA,
  });

  @override
  ConsumerState createState() => _ViewScoreTeacherScreenState();
}

class _ViewScoreTeacherScreenState
    extends ConsumerState<ViewScoreTeacherScreen> {
  bool isLoading = true;
  String selectedScoreType = 'Kiểm tra 1';
  final List<String> scoreTypes = [
    'Kiểm tra 1',
    'Kiểm tra 2',
    'Giữa khóa',
    'Cuối khóa'
  ];
  final Map<String, Map<String, double>> scoreData = {};

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() async {
    final classId = widget.classA?.id;
    if (classId == null) return;

    try {
      final scores = await ref
          .read(scoreMobileTeacherViewModelProvider.notifier)
          .fetchScoresByClassId(classId);

      for (var score in scores) {
        final studentId = score.student?.id;
        if (studentId == null) continue;

        void setScore(String type, double? value) {
          if (value == null) return;
          scoreData[type] ??= {};
          scoreData[type]![studentId] = value;
        }

        setScore('Kiểm tra 1', score.scoreTest1);
        setScore('Kiểm tra 2', score.scoreTest2);
        setScore('Giữa khóa', score.scoreMidterm);
        setScore('Cuối khóa', score.scoreFinal);
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Student> students = widget.classA?.students ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem điểm'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildScoreTypeDropdown(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildScoreTable(students)),
                ],
              ),
            ),
    );
  }

  Widget _buildScoreTypeDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 155,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedScoreType,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              items: scoreTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedScoreType = value;
                  });
                }
              },
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreTable(List<Student> students) {
    final currentScores = scoreData[selectedScoreType] ?? {};

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: const [
                Expanded(
                    flex: 1,
                    child: Center(
                        child: Text('STT',
                            style: TextStyle(fontWeight: FontWeight.w600)))),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: Text('Mã HS',
                            style: TextStyle(fontWeight: FontWeight.w600)))),
                Expanded(
                    flex: 4,
                    child: Center(
                        child: Text('Họ tên',
                            style: TextStyle(fontWeight: FontWeight.w600)))),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: Text('Điểm',
                            style: TextStyle(fontWeight: FontWeight.w600)))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.separated(
                itemCount: students.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  final student = students[index];
                  final double? score = currentScores[student.id];
                  return Container(
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Center(child: Text('${index + 1}'))),
                        Expanded(
                            flex: 2,
                            child:
                                Center(child: Text(student.studentCode ?? ''))),
                        Expanded(flex: 4, child: Text(student.fullName ?? '')),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(formatScore(score)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatScore(double? score) {
    if (score == null) return '_';
    if (score % 1 == 0) {
      return score.toInt().toString(); // Bỏ phần .0
    }
    return score.toString();
  }
}
