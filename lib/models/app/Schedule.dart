import 'package:flutter/material.dart';

import '../../resources/constains/constants.dart';

class Schedule {
  final String? id;
  final String? classId;
  final DayOfWeek? dayOfWeek;
  final String? startTime;
  final String? endTime;

  Schedule({
    this.id,
    this.classId,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String?,
      classId: json['classId'] as String?,
      dayOfWeek: json['dayOfWeek'] != null ? DayOfWeek.fromString(json['dayOfWeek']) : null,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'dayOfWeek': dayOfWeek?.toJson(),
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
