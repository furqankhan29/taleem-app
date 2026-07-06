import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/modules/ai/bindings/ai_binding.dart';
import 'package:taleem/modules/ai/views/ai_chat_screen.dart';
import 'package:taleem/modules/attendance/bindings/attendance_binding.dart';
import 'package:taleem/modules/attendance/views/attendance_history_screen.dart';
import 'package:taleem/modules/attendance/views/attendance_mark_screen.dart';
import 'package:taleem/modules/auth/bindings/auth_binding.dart';
import 'package:taleem/modules/auth/views/email_verification_screen.dart';
import 'package:taleem/modules/auth/views/forgot_password_screen.dart';
import 'package:taleem/modules/auth/views/login_screen.dart';
import 'package:taleem/modules/auth/views/signup_screen.dart';
import 'package:taleem/modules/auth/views/splash_screen.dart';
import 'package:taleem/modules/batches/bindings/batch_binding.dart';
import 'package:taleem/modules/batches/views/screens/batch_detail_screen.dart';
import 'package:taleem/modules/batches/views/screens/batch_list_screen.dart';
import 'package:taleem/modules/calendar/bindings/calendar_binding.dart';
import 'package:taleem/modules/calendar/views/calendar_screen.dart';
import 'package:taleem/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:taleem/modules/dashboard/views/dashboard_screen.dart';
import 'package:taleem/modules/exams/bindings/exam_binding.dart';
import 'package:taleem/modules/exams/views/screens/exam_detail_screen.dart';
import 'package:taleem/modules/exams/views/screens/exam_list_screen.dart';
import 'package:taleem/modules/fees/bindings/fee_binding.dart';
import 'package:taleem/modules/fees/views/fee_collect_screen.dart';
import 'package:taleem/modules/fees/views/fee_management_screen.dart';
import 'package:taleem/modules/fees/views/fee_receipt_screen.dart';
import 'package:taleem/modules/homework/bindings/homework_binding.dart';
import 'package:taleem/modules/homework/views/screens/homework_detail_screen.dart';
import 'package:taleem/modules/homework/views/screens/homework_list_screen.dart';
import 'package:taleem/modules/notifications/bindings/notification_binding.dart';
import 'package:taleem/modules/notifications/views/notification_screen.dart';
import 'package:taleem/modules/parents/bindings/parent_binding.dart';
import 'package:taleem/modules/parents/views/screens/parent_detail_screen.dart';
import 'package:taleem/modules/parents/views/screens/parent_list_screen.dart';
import 'package:taleem/modules/reports/bindings/report_binding.dart';
import 'package:taleem/modules/reports/views/screens/analytics_dashboard_screen.dart';
import 'package:taleem/modules/reports/views/screens/attendance_report_screen.dart';
import 'package:taleem/modules/reports/views/screens/fee_report_screen.dart';
import 'package:taleem/modules/reports/views/screens/student_report_screen.dart';
import 'package:taleem/modules/settings/bindings/settings_binding.dart';
import 'package:taleem/modules/settings/views/screens/profile_screen.dart';
import 'package:taleem/modules/settings/views/screens/settings_screen.dart';
import 'package:taleem/modules/students/bindings/student_binding.dart';
import 'package:taleem/modules/students/views/student_detail_screen.dart';
import 'package:taleem/modules/students/views/student_form_screen.dart';
import 'package:taleem/modules/students/views/student_list_screen.dart';
import 'package:taleem/modules/subjects/bindings/subject_binding.dart';
import 'package:taleem/modules/subjects/views/screens/subject_detail_screen.dart';
import 'package:taleem/modules/subjects/views/screens/subject_list_screen.dart';
import 'package:taleem/modules/teachers/bindings/teacher_binding.dart';
import 'package:taleem/modules/teachers/views/screens/teacher_detail_screen.dart';
import 'package:taleem/modules/teachers/views/screens/teacher_list_screen.dart';
import 'package:taleem/modules/timetable/bindings/timetable_binding.dart';
import 'package:taleem/modules/timetable/views/timetable_screen.dart';
import 'package:taleem/modules/whatsapp/bindings/whatsapp_binding.dart';
import 'package:taleem/modules/whatsapp/views/whatsapp_screen.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => const EmailVerificationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.studentList,
      page: () => const StudentListScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentDetail,
      page: () => const StudentDetailScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentForm,
      page: () => const StudentFormScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.attendance,
      page: () => const AttendanceHistoryScreen(),
      binding: AttendanceBinding(),
    ),
    GetPage(
      name: AppRoutes.attendanceMark,
      page: () => const AttendanceMarkScreen(),
      binding: AttendanceBinding(),
    ),
    GetPage(
      name: AppRoutes.aiAssistant,
      page: () => const AIChatScreen(),
      binding: AIBinding(),
    ),
    GetPage(
      name: AppRoutes.aiHistory,
      page: () => const AIHistoryScreen(),
      binding: AIBinding(),
    ),
    GetPage(
      name: AppRoutes.feeManagement,
      page: () => const FeeManagementScreen(),
      binding: FeeBinding(),
    ),
    GetPage(
      name: AppRoutes.feeCollection,
      page: () => const FeeCollectScreen(),
      binding: FeeBinding(),
    ),
    GetPage(
      name: AppRoutes.feeReceipt,
      page: () => const FeeReceiptScreen(),
      binding: FeeBinding(),
    ),
    GetPage(
      name: AppRoutes.whatsappReminders,
      page: () => const WhatsappScreen(),
      binding: WhatsappBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const AnalyticsDashboardScreen(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.reportAttendance,
      page: () => const AttendanceReportScreen(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.reportFee,
      page: () => const FeeReportScreen(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.reportStudent,
      page: () => const StudentReportScreen(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherList,
      page: () => const TeacherListScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherDetail,
      page: () => const TeacherDetailScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherForm,
      page: () => const TeacherDetailScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.parentList,
      page: () => const ParentListScreen(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.parentDetail,
      page: () => const ParentDetailScreen(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.batchList,
      page: () => const BatchListScreen(),
      binding: BatchBinding(),
    ),
    GetPage(
      name: AppRoutes.batchForm,
      page: () => const BatchDetailScreen(),
      binding: BatchBinding(),
    ),
    GetPage(
      name: AppRoutes.subjectList,
      page: () => const SubjectListScreen(),
      binding: SubjectBinding(),
    ),
    GetPage(
      name: AppRoutes.subjectForm,
      page: () => const SubjectDetailScreen(),
      binding: SubjectBinding(),
    ),
    GetPage(
      name: AppRoutes.homeworkList,
      page: () => const HomeworkListScreen(),
      binding: HomeworkBinding(),
    ),
    GetPage(
      name: AppRoutes.homeworkForm,
      page: () => const HomeworkDetailScreen(),
      binding: HomeworkBinding(),
    ),
    GetPage(
      name: AppRoutes.examList,
      page: () => const ExamListScreen(),
      binding: ExamBinding(),
    ),
    GetPage(
      name: AppRoutes.examForm,
      page: () => const ExamDetailScreen(),
      binding: ExamBinding(),
    ),
    GetPage(
      name: AppRoutes.examResults,
      page: () => const ExamDetailScreen(),
      binding: ExamBinding(),
    ),
    GetPage(
      name: AppRoutes.timetable,
      page: () => const TimetableScreen(),
      binding: TimetableBinding(),
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarScreen(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.activityLogs,
      page: () => const _PlaceholderScreen(title: 'Activity Logs'),
    ),
  ];
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Text(
          '$title Page (Under Construction)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
