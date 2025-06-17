import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/viewmodels/mobile/classA_mobile_user_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../models/app/Account.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../viewmodels/mobile/classA_mobile_teacher_view_model.dart';

class ScheduleUserScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const ScheduleUserScreen({required this.studentId, super.key});

  @override
  ConsumerState createState() => _ScheduleUserScreenState();
}

class _ScheduleUserScreenState
    extends ConsumerState<ScheduleUserScreen> with HelperMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isLoading = true;
  final Map<DateTime, List<String>> _schedule = {};


  void _fetchAndMapSchedule(String studentId) async {
    showLoading(context, show: true);
    final response = await ref
        .read(classaMobileUserViewModelProvider.notifier)
        .fetchClassAUser(id: studentId);

    final Map<DateTime, List<String>> scheduleMap = {};

    for (final classItem in response) {
      final teacherName = classItem.teacher?.fullName;
      final className = classItem.className;
      final startDate = DateTime.parse(classItem.startDate.toString()); // yyyy-MM-dd
      final endDate = DateTime.parse(classItem.endDate.toString());

      for (final schedule in classItem.schedules ?? []) {
        final weekday = schedule.dayOfWeek.weekdayNumber;

        // Lặp qua các tuần trong khoảng từ startDate đến endDate
        DateTime date = startDate;
        while (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
          if (date.weekday == weekday) {
            final timeString =
                '(${
                schedule.startTime.substring(0, 5)
            } - ${
                schedule.endTime.substring(0, 5)
            })';
            final event = '$className $timeString $teacherName';

            // Gộp vào map
            scheduleMap.putIfAbsent(date, () => []).add(event);
          }
          date = date.add(Duration(days: 1));
        }
      }
    }
    showLoading(context, show: false);
    setState(() {
      _schedule.clear();
      _schedule.addAll(scheduleMap);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAndMapSchedule(widget.studentId!.toString());
  }

  List<String> _getEventsForDay(DateTime day) {
    return _schedule[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay);
    final dayFormatted =
        '${DateFormat.EEEE('vi_VN').format(_selectedDay)}, ${DateFormat.yMMMd('vi_VN').format(_selectedDay)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch học',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, // màu của nút quay lại
        ),
      ),
      body:  _isLoading
          ? SizedBox.shrink()
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              locale: 'vi_VN',
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              calendarFormat: CalendarFormat.month,
              daysOfWeekHeight: 30,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Tháng',
              },
              headerStyle: HeaderStyle(
                titleCentered: true, // Ra giữa
                titleTextFormatter: (date, locale) {
                  // Format "Tháng M, YYYY" thay vì "tháng m, yyyy"
                  final month = DateFormat.M(locale).format(date);
                  final year = DateFormat.y(locale).format(date);
                  return 'Tháng $month, $year';
                },
                formatButtonVisible: false, // Ẩn nút "2 tuần"
              ),
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                dayFormatted,
                style: AppTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('Không có lịch học.'))
                : Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final event =
                    events[index]; // ví dụ: 'Toán 8A (7:00 - 8:30)'
                    final className = event.split(' (')[0];

                    final startParen = event.indexOf('(');
                    final endParen = event.indexOf(')');

                    final timeRange = (startParen != -1 && endParen != -1 && endParen > startParen)
                        ? event.substring(startParen + 1, endParen)
                        : '';

                    final times = timeRange.split(' - ');
                    final startTime = times.isNotEmpty ? times[0] : '';
                    final endTime = times.length > 1 ? times[1] : '';

                    final teacherName = (endParen != -1 && endParen + 1 < event.length)
                        ? event.substring(endParen + 1).trim()
                        : '';

                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, right: 8.0, bottom: 8.0, left: 16.9),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Color(0xFFE3F2F6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    startTime,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    width: 2,
                                    height: 20,
                                    color: Colors.grey.shade400,
                                  ),
                                  Text(
                                    endTime,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 1,
                                height: 60,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      className,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "GV: $teacherName",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
