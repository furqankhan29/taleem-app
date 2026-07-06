abstract class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  
  static const String dashboard = '/dashboard';
  static const String studentList = '/students';
  static const String studentDetail = '/students/:id';
  static const String studentForm = '/students/form';
  
  static const String attendance = '/attendance';
  static const String attendanceMark = '/attendance/mark';
  static const String feeManagement = '/fees';
  static const String feeCollection = '/fees/collect';
  static const String feeReceipt = '/fees/receipt';
  
  static const String aiAssistant = '/ai-assistant';
  static const String aiHistory = '/ai-assistant/history';
  static const String whatsappReminders = '/whatsapp';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  static const String teacherList = '/teachers';
  static const String teacherDetail = '/teachers/:id';
  static const String teacherForm = '/teachers/form';
  
  static const String parentList = '/parents';
  static const String parentDetail = '/parents/:id';
  
  static const String batchList = '/batches';
  static const String batchForm = '/batches/form';
  
  static const String subjectList = '/subjects';
  static const String subjectForm = '/subjects/form';
  
  static const String homeworkList = '/homework';
  static const String homeworkForm = '/homework/form';
  
  static const String examList = '/exams';
  static const String examForm = '/exams/form';
  static const String examResults = '/exams/results';
  
  static const String timetable = '/timetable';
  static const String calendar = '/calendar';
  static const String reports = '/reports';
  static const String reportAttendance = '/reports/attendance';
  static const String reportFee = '/reports/fee';
  static const String reportStudent = '/reports/student';
  static const String reportExport = '/reports/export';

  static const String activityLogs = '/activity-logs';
}
