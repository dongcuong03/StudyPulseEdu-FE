import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_pulse_edu/models/app/Score.dart';

import 'package:study_pulse_edu/viewmodels/mobile/score_mobile_user_view_model.dart';

class ScoreUserScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const ScoreUserScreen({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState createState() => _ScoreUserScreenState();
}

class _ScoreUserScreenState extends ConsumerState<ScoreUserScreen> {
  bool isLoading = true;
  String selectedScoreType = 'Kiểm tra 1';
  final List<String> scoreTypes = [
    'Kiểm tra 1',
    'Kiểm tra 2',
    'Giữa khóa',
    'Cuối khóa'
  ];
  List<Score> scores = [];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() async {
    final studentId = widget.studentId;
    if (studentId == null) return;

    try {
      final fetchedScores = await ref
          .read(scoreMobileUserViewModelProvider.notifier)
          .fetchScoresByStudentId(studentId);

      setState(() {
        scores = fetchedScores;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(child: _buildScoreTable()),
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

  Widget _buildScoreTable() {
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
                    flex: 5,
                    child: Center(
                        child: Text('Lớp học',
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
                itemCount: scores.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  final score = scores[index];

                  double? value;
                  switch (selectedScoreType) {
                    case 'Kiểm tra 1':
                      value = score.scoreTest1;
                      break;
                    case 'Kiểm tra 2':
                      value = score.scoreTest2;
                      break;
                    case 'Giữa khóa':
                      value = score.scoreMidterm;
                      break;
                    case 'Cuối khóa':
                      value = score.scoreFinal;
                      break;
                  }

                  return Container(
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Center(child: Text('${index + 1}'))),
                        Expanded(
                            flex: 5,
                            child: Text(score.classRoom?.className ?? '')),
                        Expanded(
                            flex: 2,
                            child: Center(child: Text(formatScore(value)))),
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
    if (score % 1 == 0) return score.toInt().toString(); // bỏ phần .0
    return score.toString();
  }
}
