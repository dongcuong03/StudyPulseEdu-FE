import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/models/app/Assignment.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/resources/utils/data_sources/local.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/attendance/view_attendance_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/message/message_teacher_detail_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/message/message_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/academic_result/academic_result_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/assignment/assignment_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/assignment/grade_assignment_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/assignment/grade_two_assignment_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/attendance/attendance_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/attendance/attendance_teacher_three_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/attendance/attendance_teacher_two_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/classes/class_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/classes/view_class_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/home/home_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/schedule/schedule_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/score/enter_score_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/score/score_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/score/view_score_teacher_screen.dart';
import 'package:study_pulse_edu/views/mobile/login_mobile_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/assignment/assignment_user_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/assignment/submission_user_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/assignment/view_submission_user_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/home/home_user_screen.dart';
import 'package:study_pulse_edu/routes/route_const.dart';
import 'package:study_pulse_edu/views/mobile/user/message/message_user_detail_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/message/message_user_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/notification/notification_user_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/notification/view_notification_user_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/schedule/schedule_user_screen.dart';
import 'package:study_pulse_edu/views/mobile/user/score/score_user_screen.dart';

import '../models/app/Account.dart';
import '../models/app/NotificationApp.dart';
import '../models/app/Student.dart';
import '../views/mobile/Teacher/assignment/assign_assignment_teacher_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyRouterMobile {
  static Future<GoRouter> createRouter() async {
    final sharedPre = await SharedPre.instance;
    final token =
        await sharedPre.getString(SharedPrefsConstants.ACCESS_TOKEN_KEY);
    final role = await sharedPre.getString(SharedPrefsConstants.USER_ROLE_KEY);

    String initialLocation;

    if (token == null) {
      initialLocation = '/login_mobile';
    } else {
      switch (role) {
        case 'TEACHER':
          initialLocation = '/home_teacher';
          break;
        case 'PARENT':
          initialLocation = '/home_user';
          break;
        default:
          initialLocation = '/';
      }
    }

    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          name: RouteConstants.loginMobileRouteName,
          path: '/login_mobile',
          pageBuilder: (context, state) =>
              MyRouterMobile.buildSlideTransitionPage(
                  const LoginMobileScreen()),
        ),
        GoRoute(
          name: RouteConstants.homeTeacherRouteName,
          path: '/home_teacher',
          pageBuilder: (context, state) =>
              MyRouterMobile.buildSlideTransitionPage(
                  const HomeTeacherScreen()),
        ),
        GoRoute(
            name: RouteConstants.teacherScheduleRouteName,
            path: '/home_teacher/teacher_schedule',
            pageBuilder: (context, state) {
              final account = state.extra as Account?;
              return MyRouterMobile.buildSlideTransitionPage(
                ScheduleTeacherScreen(account: account),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherClassRouteName,
            path: '/home_teacher/teacher_class',
            pageBuilder: (context, state) {
              final account = state.extra as Account?;
              return MyRouterMobile.buildSlideTransitionPage(
                ClassTeacherScreen(account: account),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherViewClassRouteName,
            path: '/home_teacher/teacher_class/teacher_view_class',
            pageBuilder: (context, state) {
              final classID = state.extra as String?;
              return MyRouterMobile.buildSlideTransitionPage(
                ViewClassTeacherScreen(classID: classID),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherAssignmentRouteName,
            path: '/home_teacher/teacher_assignment',
            pageBuilder: (context, state) {
              final account = state.extra as Account?;
              return MyRouterMobile.buildSlideTransitionPage(
                AssignmentTeacherScreen(account: account),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherGradeAssignmentRouteName,
            path: '/home_teacher/teacher_grade_assignment',
            pageBuilder: (context, state) {
              final map = state.extra as Map<String, dynamic>?;
              final account = map?['account'] as Account?;
              final assignment = map?['assignment'] as Assignment?;
              return MyRouterMobile.buildSlideTransitionPage(
                GradeAssignmentTeacherScreen(
                  account: account,
                  assignment: assignment,
                ),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherGradeTwoAssignmentRouteName,
            path:
                '/home_teacher/teacher_grade_assignment/teacher_grade_two_assignment',
            pageBuilder: (context, state) {
              final map = state.extra as Map<String, dynamic>?;
              final assignment = map?['assignment'] as Assignment?;
              final student = map?['student'] as Student?;
              final onClose = map?['onClose'] as VoidCallback?;
              return MyRouterMobile.buildSlideTransitionPage(
                GradeTwoAssignmentTeacherScreen(
                  assignment: assignment,
                  student: student,
                  onClose: onClose,
                ),
              );
            }),
        GoRoute(
          name: RouteConstants.teacherAssignAssignmentRouteName,
          path: '/home_teacher/teacher_assignment/teacher_assign_assignment',
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>?;
            final account = map?['account'] as Account?;
            final onClose = map?['onClose'] as VoidCallback?;
            return MyRouterMobile.buildSlideTransitionPage(
              AssignAssignmentTeacherScreen(account: account, onClose: onClose),
            );
          },
        ),
        GoRoute(
            name: RouteConstants.teacherScoreRouteName,
            path: '/home_teacher/teacher_score',
            pageBuilder: (context, state) {
              final account = state.extra as Account?;
              return MyRouterMobile.buildSlideTransitionPage(
                ScoreTeacherScreen(account: account),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherEnterScoreRouteName,
            path: '/home_teacher/teacher_score/teacher_enter_score',
            pageBuilder: (context, state) {
              final map = state.extra as Map<String, dynamic>?;
              final account = map?['account'] as Account?;
              final classA = map?['classA'] as ClassA?;
              final onClose = map?['onClose'] as VoidCallback?;
              return MyRouterMobile.buildSlideTransitionPage(
                EnterScoreTeacherScreen(
                  account: account,
                  classA: classA,
                  onClose: onClose,
                ),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherViewScoreRouteName,
            path: '/home_teacher/teacher_score/teacher_view_score',
            pageBuilder: (context, state) {
              final map = state.extra as Map<String, dynamic>?;
              final account = map?['account'] as Account?;
              final classA = map?['classA'] as ClassA?;
              return MyRouterMobile.buildSlideTransitionPage(
                ViewScoreTeacherScreen(account: account, classA: classA),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherAttendanceRouteName,
            path: '/home_teacher/teacher_attendance',
            pageBuilder: (context, state) {
              final account = state.extra as Account?;
              return MyRouterMobile.buildSlideTransitionPage(
                AttendanceTeacherScreen(account: account),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherAttendanceTwoRouteName,
            path: '/home_teacher/teacher_attendance/teacher_attendance_two',
            pageBuilder: (context, state) {
              final map = state.extra as Map<String, dynamic>?;
              final account = map?['account'] as Account?;
              final classA = map?['classA'] as ClassA?;
              return MyRouterMobile.buildSlideTransitionPage(
                AttendanceTeacherTwoScreen(account: account, classA: classA),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherAttendanceThreeRouteName,
            path:
                '/home_teacher/teacher_attendance/teacher_attendance_two/teacher_attendance_three',
            pageBuilder: (context, state) {
              final map = state.extra as Map<String, dynamic>?;
              final account = map?['account'] as Account?;
              final classA = map?['classA'] as ClassA?;
              final date = map?['date'] as DateTime?;
              final onClose = map?['onClose'] as VoidCallback?;
              return MyRouterMobile.buildSlideTransitionPage(
                AttendanceTeacherThreeScreen(
                  account: account,
                  classA: classA,
                  date: date,
                  onClose: onClose,
                ),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherViewAttendanceRouteName,
            path:
                '/home_teacher/teacher_attendance/teacher_attendance_two/teacher_view_attendance',
            pageBuilder: (context, state) {
              final map = state.extra as Map<String, dynamic>?;
              final account = map?['account'] as Account?;
              final classA = map?['classA'] as ClassA?;
              final date = map?['date'] as DateTime?;
              return MyRouterMobile.buildSlideTransitionPage(
                ViewAttendanceTeacherScreen(
                  account: account,
                  classA: classA,
                  date: date,
                ),
              );
            }),
        GoRoute(
          name: RouteConstants.teacherAcademicResultRouteName,
          path: '/home_teacher/teacher_academic_result',
          pageBuilder: (context, state) =>
              MyRouterMobile.buildSlideTransitionPage(
                  const AcademicResultTeacherScreen()),
        ),
        GoRoute(
          name: RouteConstants.teacherMessageRouteName,
          path: '/home_teacher/teacher_message',
            pageBuilder: (context, state) {
              final accountId = state.extra as String?;
              return MyRouterMobile.buildSlideTransitionPage(
                MessageTeacherScreen(accountId: accountId),
              );
            }),
        GoRoute(
            name: RouteConstants.teacherMessageDetailRouteName,
            path: '/home_teacher/teacher_message/teacher_message_detail',
            pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>?;
            final accountId = map?['accountId'] as String?;
            final accountParentId = map?['accountParentId'] as String?;
            final parentName = map?['parentName'] as String?;
            final onClose = map?['onClose'] as VoidCallback?;
            return MyRouterMobile.buildSlideTransitionPage(
                MessageTeacherDetailScreen(
                    accountParentId: accountParentId,
                    parentName: parentName,
                    accountId: accountId,
                    onClose: onClose));
          },
        ),

        GoRoute(
          name: RouteConstants.homeUserRouteName,
          path: '/home_user',
          pageBuilder: (context, state) =>
              MyRouterMobile.buildSlideTransitionPage(const HomeUserScreen()),
        ),
        GoRoute(
            name: RouteConstants.userMessageRouteName,
            path: '/home_user/user_message',
            pageBuilder: (context, state) {
              final accountId = state.extra as String?;
              return MyRouterMobile.buildSlideTransitionPage(
                MessageUserScreen(accountId: accountId),
              );
            }),
        GoRoute(
          name: RouteConstants.userMessageDetailRouteName,
          path: '/home_user/user_message/user_message_detail',
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>?;
            final accountId = map?['accountId'] as String?;
            final accountTeacherId = map?['accountTeacherId'] as String?;
            final teacherName = map?['teacherName'] as String?;
            final onClose = map?['onClose'] as VoidCallback?;
            return MyRouterMobile.buildSlideTransitionPage(
                MessageUserDetailScreen(
                    accountId: accountId,
                    accountTeacherId: accountTeacherId,
                    teacherName: teacherName,
                    onClose: onClose));
          },
        ),
        GoRoute(
          name: RouteConstants.userNotificationRouteName,
          path: '/home_user/user_notification',
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>?;
            final accountId = map?['accountId'] as String?;
            final onClose = map?['onClose'] as VoidCallback?;
            return MyRouterMobile.buildSlideTransitionPage(
                NotificationUserScreen(accountId: accountId, onClose: onClose));
          },
        ),
        GoRoute(
          name: RouteConstants.userViewNotificationRouteName,
          path: '/home_user/user_notification/user_view_notification',
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>?;
            final notificationApp = map?['notificationApp'] as NotificationApp?;
            final onClose = map?['onClose'] as VoidCallback?;
            return MyRouterMobile.buildSlideTransitionPage(
                ViewNotificationUserScreen(
                    notificationApp: notificationApp, onClose: onClose));
          },
        ),
        GoRoute(
            name: RouteConstants.userScheduleRouteName,
            path: '/home_user/user_schedule',
            pageBuilder: (context, state) {
              final studentId = state.extra as String?;
              return MyRouterMobile.buildSlideTransitionPage(
                ScheduleUserScreen(studentId: studentId),
              );
            }),
        GoRoute(
            name: RouteConstants.userAssignmentRouteName,
            path: '/home_user/user_assignment',
            pageBuilder: (context, state) {
              final map = state.extra as Map<String, dynamic>?;
              final studentId = map?['studentId'] as String?;
              final studentName = map?['studentName'] as String?;
              final studentCode = map?['studentCode'] as String?;
              return MyRouterMobile.buildSlideTransitionPage(
                AssignmentUserScreen(
                    studentId: studentId,
                    studentName: studentName,
                    studentCode: studentCode),
              );
            }),
        GoRoute(
          name: RouteConstants.userSubmissionRouteName,
          path: '/home_user/user_assignment/user_submisstion',
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>?;
            final studentId = map?['studentId'] as String?;
            final assignmentId = map?['assignmentId'] as String?;
            final onClose = map?['onClose'] as VoidCallback?;
            return MyRouterMobile.buildSlideTransitionPage(
              SubmissionUserScreen(
                  studentId: studentId,
                  assignmentId: assignmentId,
                  onClose: onClose),
            );
          },
        ),
        GoRoute(
          name: RouteConstants.userViewSubmissionRouteName,
          path: '/home_user/user_assignment/user_view_submisstion',
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>?;
            final studentId = map?['studentId'] as String?;
            final studentName = map?['studentName'] as String?;
            final studentCode = map?['studentCode'] as String?;
            final className = map?['className'] as String?;
            final title = map?['title'] as String?;
            final assignmentId = map?['assignmentId'] as String?;
            final onClose = map?['onClose'] as VoidCallback?;
            return MyRouterMobile.buildSlideTransitionPage(
              ViewSubmissionUserScreen(
                  studentId: studentId,
                  studentName: studentName,
                  studentCode: studentCode,
                  className: className,
                  title: title,
                  assignmentId: assignmentId,
                  onClose: onClose),
            );
          },
        ),
        GoRoute(
            name: RouteConstants.userScoreRouteName,
            path: '/home_user/user_score',
            pageBuilder: (context, state) {
              final studentId = state.extra as String?;
              return MyRouterMobile.buildSlideTransitionPage(
                ScoreUserScreen(studentId: studentId),
              );
            }),
      ],
      redirect: (context, state) async {
        final token =
            await sharedPre.getString(SharedPrefsConstants.ACCESS_TOKEN_KEY);
        final role =
            await sharedPre.getString(SharedPrefsConstants.USER_ROLE_KEY);
        final currentPath = state.uri.path;
        final isLoggingIn = currentPath == '/login_mobile';

        if (token == null && !isLoggingIn) {
          return '/login_mobile';
        }

        if (token != null && isLoggingIn) {
          switch (role) {
            case 'TEACHER':
              return '/home_teacher';
            case 'PARENT':
              return '/home_user';
            default:
              return '/';
          }
        }

        return null;
      },
    );
  }

  static CustomTransitionPage<T> buildSlideTransitionPage<T>(Widget child) {
    return CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide from right
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }
}
