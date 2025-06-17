import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/utils/helpers/helper_mixin.dart';

import '../../../../models/app/Account.dart';
import '../../../../models/app/ClassA.dart';
import '../../../../routes/route_const.dart';
import '../../../../viewmodels/mobile/attendance_teacher_view_model.dart';

class AttendanceTeacherTwoScreen extends ConsumerStatefulWidget {
  final Account? account;
  final ClassA? classA;

  const AttendanceTeacherTwoScreen({
    required this.account,
    required this.classA,
    super.key,
  });

  @override
  ConsumerState createState() => _AttendanceTeacherTwoScreenState();
}

class _AttendanceTeacherTwoScreenState
    extends ConsumerState<AttendanceTeacherTwoScreen> with HelperMixin{
  late List<DateTime> attendedDates = [];

  late  List<DateTime> scheduleDays;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scheduleDays = _generateScheduleDates();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dates = await ref
          .read(attendanceTeacherViewModelProvider.notifier)
          .getAttendanceByClass(widget.classA!.id!);
      if (dates != null) {
        setState(() {
          attendedDates = dates;
        });
        _scrollToLatestAttendance();
      }
    });
  }

  List<DateTime> _generateScheduleDates() {
    List<DateTime> dates = [];

    final startDate = widget.classA!.startDate!;
    final endDate = widget.classA!.endDate!;
    final scheduleWeekdays = widget.classA!.schedules
        ?.map((e) => e.dayOfWeek?.weekdayNumber)
        .toList();

    if (scheduleWeekdays == null || scheduleWeekdays.isEmpty) {
      return dates;
    }

    DateTime current = startDate;

    while (!current.isAfter(endDate)) {
      if (scheduleWeekdays.contains(current.weekday)) {
        dates.add(DateTime(current.year, current.month, current.day));
      }
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }



  void _scrollToLatestAttendance() {
    final lastIndex = scheduleDays.lastIndexWhere(
      (date) => attendedDates.any((d) => isSameDate(d, date)),
    );

    if (lastIndex != -1) {
      const itemHeight = 110.0;
      _scrollController.animateTo(
        lastIndex * itemHeight,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Điểm danh',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text('${attendedDates.length}/${scheduleDays.length}', style: TextStyle(color: Colors.white, fontSize: 16),),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                        child: Center(
                          child: Text(
                            widget.classA?.className ?? '',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54
                            ),
                          ),
                        ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: Center(
                          child: Text(
                            '${formatDate(widget.classA!.startDate.toString())} - ${formatDate(widget.classA!.endDate.toString())}',
                            style: TextStyle(
                                fontSize: 14,
                              color: Colors.blue
                            ),
                          ),
                        ))
                  ],
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: scheduleDays.length,
                itemBuilder: (context, index) {
                  final date = scheduleDays[index];
                  final isAttended =
                      attendedDates.any((d) => isSameDate(d, date));
                  final isToday = isSameDate(date, today);
                  final formatted =
                      DateFormat('EEEE, dd/MM/yyyy', 'vi').format(date);

                  Color cardColor;
                  if (isAttended) {
                    cardColor = Colors.white;
                  } else if (isToday) {
                    cardColor = Colors.white;
                  } else {
                    cardColor = Colors.grey.shade200;
                  }

                  return SizedBox(
                    height: 108,
                    child: GestureDetector(
                      onTap: isAttended ? () => _viewAttendance(date) : null,
                      child: Card(
                        color: cardColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  formatted,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isAttended || isToday ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                              if (isToday)
                                IconButton(
                                  onPressed: () => _takeAttendance(date),
                                  icon: const Icon(
                                    Icons.how_to_reg,
                                    size: 27,
                                  ),
                                  color: Colors.blue,
                                )
                              else if (isAttended)
                                const Icon(
                                  Icons.check,
                                  size: 27,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ),
                      ),
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

  void _viewAttendance(DateTime date) {
    pushedName(context, RouteConstants.teacherViewAttendanceRouteName,
      extra: {
        "account":  widget.account,
        "classA": widget.classA,
        "date": date,
      },);
  }

  void _takeAttendance(DateTime date) {
    pushedName(context, RouteConstants.teacherAttendanceThreeRouteName,
      extra: {
        "account":  widget.account,
        "classA": widget.classA,
        "date": date,
        "onClose": (){
          showSuccessToast("Ghi nhận điểm danh thành công");
        }
      },);
  }
}
