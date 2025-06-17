import '../../resources/constains/constants.dart';
import 'Parent.dart';
import 'Teacher.dart';

class Account {
  final String? id;
  final String? phone;
  final String?password;
  final Role? role;
  final bool? isActive;
  final DateTime? lastOnline;
  Parent? parent;
  Teacher? teacher;

  Account({
    this.id,
    this.phone,
    this.password,
    this.role,
    this.isActive,
    this.lastOnline,
    this.parent,
    this.teacher,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String?,
      role: Role.fromString(json['role'] as String?),
      isActive: json['isActive'] as bool?,
      lastOnline: json['lastOnline'] != null
          ? DateTime.tryParse(json['lastOnline'])
          : null,
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null,
      parent: json['parent'] != null ? Parent.fromJson(json['parent']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'phone': phone,
      'password': password,
      'role': role?.toJson(),
      'isActive': isActive,
      'lastOnline': lastOnline?.toIso8601String(),
    };

    // Chỉ serialize teacher nếu role là teacher và teacher != null
    if (role == Role.TEACHER && teacher != null) {
      data['teacher'] = teacher!.toJson();
    }
    // Chỉ serialize parent nếu role là parent và parent != null
    else if (role == Role.PARENT && parent != null) {
      data['parent'] = parent!.toJson();
    }

    return data;
  }
  @override
  String toString() {
    return 'Account(id: $id, phone: $phone, password: $password, role: $role, isActive: $isActive, lastOnline: $lastOnline, parent: $parent, teacher: $teacher)';
  }


}
