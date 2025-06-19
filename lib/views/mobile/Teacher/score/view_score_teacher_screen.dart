import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/models/app/Score.dart';
import 'package:study_pulse_edu/viewmodels/mobile/classA_mobile_teacher_view_model.dart';
import 'package:study_pulse_edu/viewmodels/mobile/score_mobile_teacher_view_model.dart';

import '../../../../models/app/Account.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../routes/route_const.dart';


class ViewScoreTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;
  final String? classId;
  const ViewScoreTeacherScreen({required this.account , required this.classId, super.key});

  @override
  ConsumerState createState() => _ViewScoreTeacherScreenState();
}

class _ViewScoreTeacherScreenState extends ConsumerState<ViewScoreTeacherScreen> with HelperMixin {
  List<Score> _scores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchScores();
  }

  Future<void> _fetchScores() async {
    try {
      final scores = await ref
          .read(scoreMobileTeacherViewModelProvider.notifier)
          .fetchScoresByClassId(widget.classId!);
      setState(() {
        _scores = scores;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem điểm', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                scoreHeaderCell('STT', 40),
                scoreHeaderCell('Học sinh', 160),
                scoreHeaderCell('KT1', 50),
                scoreHeaderCell('KT2', 50),
                scoreHeaderCell('GK', 50),
                scoreHeaderCell('CK', 50),
              ],
            ),
          ),
          const Divider(height: 1),
          // Data rows
          Expanded(
            child: ListView.builder(
              itemCount: _scores.length,
              itemBuilder: (context, index) {
                final s = _scores[index];
                final isEvenRow = (index + 1) % 2 == 0;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isEvenRow ? Colors.white : null,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      scoreCell('${index + 1}', 40),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 144,
                              child: Text(
                                s.student?.fullName ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              width: 144,
                              child: Text(
                                s.student?.studentCode ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),


                      scoreCell(formatScore(s.scoreTest1), 50),
                      scoreCell(formatScore(s.scoreTest2), 50),
                      scoreCell(formatScore(s.scoreMidterm), 50),
                      scoreCell(formatScore(s.scoreFinal), 50),

                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatScore(double? score) {
    if (score == null) return '-';
    final s = score.toStringAsFixed(2);
    if (s.endsWith('.00')) {
      return s.replaceAll('.00', '');
    } else if (s.endsWith('0')) {
      return s.substring(0, s.length - 1); // bỏ số 0 cuối
    } else {
      return s;
    }
  }

  Widget scoreHeaderCell(String label, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget scoreCell(String content, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(content, overflow: TextOverflow.ellipsis),
    );
  }
}
