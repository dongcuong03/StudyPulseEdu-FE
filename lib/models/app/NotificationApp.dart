import 'package:study_pulse_edu/models/app/Account.dart';
import 'package:study_pulse_edu/models/app/Student.dart';

import '../../resources/constains/constants.dart';

class NotificationApp{
  final String? id;
  final String? title;
  final String? message;
  final Account? sender;
  final Account? receiver;
  final Student? student;
  final NotificationType? type;
   bool? isRead;
  final DateTime? createdAt;
  NotificationApp({
    this.id,
    this.title,
    this.message,
    this.sender,
    this.receiver,
    this.student,
    this.type,
    this.isRead,
    this.createdAt
  });
  factory NotificationApp.fromJson(Map<String, dynamic> json) {
    return NotificationApp(
      id: json['id'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      sender: json['sender'] != null ? Account.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? Account.fromJson(json['receiver']) : null,
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
      type: json['type'] != null ? NotificationType.fromString(json['type'] as String) : null,
      isRead: json['isRead'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  // Từ object sang JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
      'student': student?.toJson(),
      'type': type?.toJson(),
      'isRead': isRead,
      'createdAt':createdAt,
    };
  }
}