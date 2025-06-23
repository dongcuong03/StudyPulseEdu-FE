import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  // static const String BASE_URL_MOBILE = 'http://192.168.87.249:8080'; //mạng dth
  static const String BASE_URL_MOBILE = 'http://192.168.4.12:8080'; // mạng wifi
  static const String BASE_URL_WEB = 'http://localhost:8080';
  static String get getBaseUrl {
    if (kIsWeb) return BASE_URL_WEB;
    if (Platform.isAndroid) return BASE_URL_MOBILE;
    return BASE_URL_WEB; // mặc định cho desktop, iOS,...
  }
  // route

}

class SharedPrefsConstants {
  static const String LANGUAGE_KEY = 'language';
  static const String ACCESS_TOKEN_KEY = 'access_token';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const USER_ROLE_KEY = 'user_role';
  static const String USER_PROFILE = 'user_profile';
  static const String FONT_SIZE_KEY = 'font_size';
  static const String REMEMBER_PASSWORD_KEY = 'remember_password';
}

enum Role {
  ADMIN,
  TEACHER,
  PARENT;

  static Role? fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ADMIN':
        return Role.ADMIN;
      case 'TEACHER':
        return Role.TEACHER;
      case 'PARENT':
        return Role.PARENT;
      default:
        throw ArgumentError('Unknown role: $value');
    }
  }

  String toJson() {
    switch (this) {
      case Role.ADMIN:
        return 'ADMIN';
      case Role.TEACHER:
        return 'TEACHER';
      case Role.PARENT:
        return 'PARENT';
    }
  }
  String get displayName {
    switch (this) {
      case Role.ADMIN:
        return 'Quản lý trung tâm';
      case Role.TEACHER:
        return 'Giáo viên';
      case Role.PARENT:
        return 'Phụ huynh';
    }
  }
}

enum TuitionStatus {
  PAID,
  UNPAID;

  static TuitionStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PAID':
        return TuitionStatus.PAID;
      case 'UNPAID':
        return TuitionStatus.UNPAID;
      default:
        throw ArgumentError('Unknown tuition status: $value');
    }
  }

  String toJson() {
    switch (this) {
      case TuitionStatus.PAID:
        return 'PAID';
      case TuitionStatus.UNPAID:
        return 'UNPAID';
    }
  }

  String get displayName {
    switch (this) {
      case TuitionStatus.PAID:
        return 'Đã nộp';
      case TuitionStatus.UNPAID:
        return 'Chưa nộp';
    }
  }
}


enum Gender {
  MALE,
  FEMALE;

  static Gender fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MALE':
        return Gender.MALE;
      case 'FEMALE':
        return Gender.FEMALE;
      default:
        throw ArgumentError('Unknown gender: $value');
    }
  }

  String toJson() {
    switch (this) {
      case Gender.MALE:
        return 'MALE';
      case Gender.FEMALE:
        return 'FEMALE';
    }
  }
  String get displayGender {
    switch (this) {
      case Gender.MALE:
        return 'Nam';
      case Gender.FEMALE:
        return 'Nữ';
    }
  }
}

enum DayOfWeek {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY;

  static DayOfWeek fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MONDAY':
        return DayOfWeek.MONDAY;
      case 'TUESDAY':
        return DayOfWeek.TUESDAY;
      case 'WEDNESDAY':
        return DayOfWeek.WEDNESDAY;
      case 'THURSDAY':
        return DayOfWeek.THURSDAY;
      case 'FRIDAY':
        return DayOfWeek.FRIDAY;
      case 'SATURDAY':
        return DayOfWeek.SATURDAY;
      case 'SUNDAY':
        return DayOfWeek.SUNDAY;
      default:
        throw ArgumentError('Unknown day of week: $value');
    }
  }

  String toJson() {
    switch (this) {
      case DayOfWeek.MONDAY:
        return 'Monday';
      case DayOfWeek.TUESDAY:
        return 'Tuesday';
      case DayOfWeek.WEDNESDAY:
        return 'Wednesday';
      case DayOfWeek.THURSDAY:
        return 'Thursday';
      case DayOfWeek.FRIDAY:
        return 'Friday';
      case DayOfWeek.SATURDAY:
        return 'Saturday';
      case DayOfWeek.SUNDAY:
        return 'Sunday';
    }
  }

  String get displayName {
    switch (this) {
      case DayOfWeek.MONDAY:
        return 'Thứ 2';
      case DayOfWeek.TUESDAY:
        return 'Thứ 3';
      case DayOfWeek.WEDNESDAY:
        return 'Thứ 4';
      case DayOfWeek.THURSDAY:
        return 'Thứ 5';
      case DayOfWeek.FRIDAY:
        return 'Thứ 6';
      case DayOfWeek.SATURDAY:
        return 'Thứ 7';
      case DayOfWeek.SUNDAY:
        return 'Chủ nhật';
    }
  }

  int get weekdayNumber {
    switch (this) {
      case DayOfWeek.MONDAY:
        return DateTime.monday; // 1
      case DayOfWeek.TUESDAY:
        return DateTime.tuesday;
      case DayOfWeek.WEDNESDAY:
        return DateTime.wednesday;
      case DayOfWeek.THURSDAY:
        return DateTime.thursday;
      case DayOfWeek.FRIDAY:
        return DateTime.friday;
      case DayOfWeek.SATURDAY:
        return DateTime.saturday;
      case DayOfWeek.SUNDAY:
        return DateTime.sunday; // 7
    }
  }
}

enum EnrollmentStatus {
  CAN_ENROLL,
  CONFLICT,
  ENROLLED;

  static EnrollmentStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CAN_ENROLL':
        return EnrollmentStatus.CAN_ENROLL;
      case 'CONFLICT':
        return EnrollmentStatus.CONFLICT;
      case 'ENROLLED':
        return EnrollmentStatus.ENROLLED;
      default:
        throw ArgumentError('Unknown enrollment status: $value');
    }
  }

  String toJson() {
    switch (this) {
      case EnrollmentStatus.CAN_ENROLL:
        return 'CAN_ENROLL';
      case EnrollmentStatus.CONFLICT:
        return 'CONFLICT';
      case EnrollmentStatus.ENROLLED:
        return 'ENROLLED';
    }
  }

  String get displayName {
    switch (this) {
      case EnrollmentStatus.CAN_ENROLL:
        return 'Có thể ghi danh';
      case EnrollmentStatus.CONFLICT:
        return 'Trùng lịch học';
      case EnrollmentStatus.ENROLLED:
        return 'Đã ghi danh';
    }
  }
}

enum ClassStatus {
  ACTIVE,
  INACTIVE;

  static ClassStatus? fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACTIVE':
        return ClassStatus.ACTIVE;
      case 'INACTIVE':
        return ClassStatus.INACTIVE;
      default:
        return null; // hoặc throw ArgumentError('Unknown status: $value');
    }
  }

  String toJson() {
    switch (this) {
      case ClassStatus.ACTIVE:
        return 'active';
      case ClassStatus.INACTIVE:
        return 'inactive';
    }
  }

  String get displayName {
    switch (this) {
      case ClassStatus.ACTIVE:
        return 'Đang hoạt động';
      case ClassStatus.INACTIVE:
        return 'Đang bị ẩn';
    }
  }
}

enum AttendanceStatus {
  PRESENT,
  ABSENT;

  static AttendanceStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PRESENT':
        return AttendanceStatus.PRESENT;
      case 'ABSENT':
        return AttendanceStatus.ABSENT;
      default:
        throw ArgumentError('Unknown attendance status: $value');
    }
  }

  String toJson() {
    switch (this) {
      case AttendanceStatus.PRESENT:
        return 'PRESENT';
      case AttendanceStatus.ABSENT:
        return 'ABSENT';
    }
  }

  String get displayName {
    switch (this) {
      case AttendanceStatus.PRESENT:
        return 'Có mặt';
      case AttendanceStatus.ABSENT:
        return 'Vắng';
    }
  }
}

enum NotificationType {
  SCORE,
  TUITION,
  ATTENDANCE,
  RESULT;

  static NotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SCORE':
        return NotificationType.SCORE;
      case 'TUITION':
        return NotificationType.TUITION;
      case 'ATTENDANCE':
        return NotificationType.ATTENDANCE;
      case 'RESULT':
        return NotificationType.RESULT;
      default:
        throw ArgumentError('Unknown notification type: $value');
    }
  }

  String toJson() {
    switch (this) {
      case NotificationType.SCORE:
        return 'SCORE';
      case NotificationType.TUITION:
        return 'TUITION';
      case NotificationType.ATTENDANCE:
        return 'ATTENDANCE';
      case NotificationType.RESULT:
        return 'RESULT';
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.SCORE:
        return 'Điểm';
      case NotificationType.TUITION:
        return 'Học phí';
      case NotificationType.ATTENDANCE:
        return 'Điểm danh';
      case NotificationType.RESULT:
        return 'Kết quả học tập';
    }
  }
}

class AppConstants {
  static const String APP_LANGUAGE = 'vi';
  static const double APP_BAR_HEIGHT = 45;
  static const String DATE_FORMAT = 'dd/MM/yyyy';
  static const String DATE_TIME_FORMAT_WITHOUT_SECOND = 'dd/MM/yyyy HH:mm';
  static const String DATE_TIME_FORMAT = 'dd/MM/yyyy HH:mm:ss';
}

class AppSettingConstants {
  static const double FONT_SIZE_SMALL = 14;
  static const double FONT_SIZE_MEDIUM = 16;
  static const double FONT_SIZE_LARGE = 20;
}

class ApiResultCodeConstants {
  static const int SUCCESS = 1;
  static const int USER_NAME_EXIST = -1; // Ten dang nhap da ton tai
  static const int REGISTERED = -2; //Dang dang ky trong 1 tien trinh khac
  static const int UNKNOWN_ERROR = -3; //Co loi gi do
  static const int USER_NOT_FOUND = -4; //Khong tim thay User
  static const int INVALID_OTP = -5; //Sai OTP
  static const int INVALID_PASSWORD = -6; //Sai Mat khau
  static const int SEND_OTP_ERROR = -7; //Sai OTP
}