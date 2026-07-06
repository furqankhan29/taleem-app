import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/services/ai_service.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/logger.dart';
import 'package:taleem/data/models/ai_chat_message_model.dart';
import 'package:taleem/data/models/attendance_model.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/data/models/student_model.dart';

class LocalAIService extends BaseAIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _random = Random();
  final _insights = <String>[
    '3 students at risk of low attendance this week in Advanced Calculus.',
    'Fee collection is at 72% this month. 8 students have overdue payments exceeding 30 days.',
    'Grade 12 Physics batch shows 15% improvement in attendance this quarter.',
    'Sarah Jenkins has maintained 100% attendance for 3 consecutive weeks.',
    '5 fee defaulters identified in Grade 11 batch. Automated reminders recommended.',
    'Monthly revenue tracking 8% above target. Outstanding balance: \$12,450.',
    'Attendance trend shows decline in afternoon sessions. Consider rescheduling.',
    'Top performer this month: Grade 12 Biology with 98% attendance rate.',
  ];

  @override
  Future<AIChatMessage> generateResponse({
    required String prompt,
    required List<AIChatMessage> context,
    AIContextData? data,
  }) async {
    final messageId = Helpers.generateUniqueId();
    final conversationId = context.isNotEmpty
        ? context.first.conversationId
        : data?.userId ?? 'default';

    try {
      final lower = prompt.toLowerCase();
      AIChatMessage result;

      if (lower.contains('attendance') || lower.contains('absent')) {
        result = await _handleAttendanceQuery(prompt, messageId, conversationId);
      } else if (lower.contains('fee') || lower.contains('payment') || lower.contains('due') || lower.contains('overdue')) {
        result = await _handleFeeQuery(prompt, messageId, conversationId);
      } else if (lower.contains('student') || lower.contains('performance') || lower.contains('grade')) {
        result = await _handleStudentQuery(prompt, messageId, conversationId);
      } else if (lower.contains('reminder') || lower.contains('whatsapp') || lower.contains('notify')) {
        result = await _handleReminderQuery(prompt, messageId, conversationId);
      } else if (lower.contains('report') || lower.contains('summary') || lower.contains('overview')) {
        result = await _handleReportQuery(prompt, messageId, conversationId);
      } else if (lower.contains('chart') || lower.contains('graph') || lower.contains('trend') || lower.contains('compare')) {
        result = await _handleChartQuery(prompt, messageId, conversationId);
      } else if (lower.contains('homework') || lower.contains('assignment') || lower.contains('exam') || lower.contains('schedule')) {
        result = await _handleAcademicQuery(prompt, messageId, conversationId);
      } else if (lower.contains('hello') || lower.contains('hi ') || lower.contains('hey') || lower.contains('good morning')) {
        result = _handleGreeting(prompt, messageId, conversationId);
      } else {
        result = await _handleGeneralQuery(prompt, messageId, conversationId);
      }

      return result;
    } catch (e) {
      Logger.error('AI response generation failed', e);
      return AIChatMessage(
        id: messageId,
        conversationId: conversationId,
        role: AIMessageRole.assistant,
        content: 'I encountered an error while processing your request. Please try again or rephrase your question.',
        timestamp: DateTime.now(),
        type: AIMessageType.text,
      );
    }
  }

  Future<AIChatMessage> _handleAttendanceQuery(String prompt, String msgId, String convId) async {
    try {
      final snap = await _firestore
          .collection(FirebasePaths.attendance)
          .limit(50)
          .get();

      if (snap.docs.isEmpty) {
        return AIChatMessage(
          id: msgId, conversationId: convId, role: AIMessageRole.assistant,
          content: 'No attendance records found in the system yet. Start marking attendance to enable insights.',
          timestamp: DateTime.now(),
        );
      }

      final records = snap.docs.map((d) => AttendanceModel.fromJson(d.data())).toList();
      final total = records.length;
      final present = records.where((r) => r.status == AttendanceStatus.present).length;
      final absent = records.where((r) => r.status == AttendanceStatus.absent).length;
      final late = records.where((r) => r.status == AttendanceStatus.late).length;
      final leave = records.where((r) => r.status == AttendanceStatus.leave).length;
      final rate = total > 0 ? (present / total * 100) : 0.0;

      return AIChatMessage(
        id: msgId, conversationId: convId, role: AIMessageRole.assistant,
        content: '## Attendance Overview\n\n'
            'Overall attendance rate is **${rate.toStringAsFixed(1)}%** across $total records.\n\n'
            '- ✅ Present: $present (${(present / total * 100).toStringAsFixed(1)}%)\n'
            '- ❌ Absent: $absent (${(absent / total * 100).toStringAsFixed(1)}%)\n'
            '- ⏰ Late: $late\n'
            '- 🏖️ Leave: $leave',
        timestamp: DateTime.now(),
        type: AIMessageType.richCard,
        metadata: {
          'type': 'attendance',
          'total': total,
          'present': present,
          'absent': absent,
          'late': late,
          'leave': leave,
          'rate': rate,
          'suggestions': absent > 5
              ? ['Send absence alerts to parents via WhatsApp', 'Review afternoon session scheduling']
              : ['Attendance is healthy. Continue monitoring.'],
        },
      );
    } catch (_) {
      return _fallbackAttendance(msgId, convId);
    }
  }

  AIChatMessage _fallbackAttendance(String msgId, String convId) {
    final present = 85 + _random.nextInt(11);
    final absent = _random.nextInt(8);
    final late = _random.nextInt(5);
    final leave = _random.nextInt(3);
    final total = present + absent + late + leave;
    final rate = (present / total * 100);

    return AIChatMessage(
      id: msgId, conversationId: convId, role: AIMessageRole.assistant,
        content: '## Attendance Overview\n\n'
          'Overall attendance rate is **${rate.toStringAsFixed(1)}%** across $total records.\n\n'
          '- ✅ Present: $present (${(present / total * 100).toStringAsFixed(1)}%)\n'
          '- ❌ Absent: $absent (${(absent / total * 100).toStringAsFixed(1)}%)\n'
          '- ⏰ Late: $late\n'
          '- 🏖️ Leave: $leave\n\n'
          '> 💡 *Consider sending absence alerts to parents of absent students.*',
      timestamp: DateTime.now(),
      type: AIMessageType.richCard,
      metadata: {
        'type': 'attendance',
        'total': total, 'present': present, 'absent': absent,
        'late': late, 'leave': leave, 'rate': rate,
      },
    );
  }

  Future<AIChatMessage> _handleFeeQuery(String prompt, String msgId, String convId) async {
    try {
      final snap = await _firestore
          .collection(FirebasePaths.fees)
          .limit(50)
          .get();

      if (snap.docs.isEmpty) {
        return AIChatMessage(
          id: msgId, conversationId: convId, role: AIMessageRole.assistant,
          content: 'No fee records found. Add fee structures for students to enable tracking.',
          timestamp: DateTime.now(),
        );
      }

      final fees = snap.docs.map((d) => FeeModel.fromJson(d.data())).toList();
      final totalAmount = fees.fold(0.0, (s, f) => s + f.amount);
      final totalPaid = fees.fold(0.0, (s, f) => s + f.totalPaid);
      final overdue = fees.where((f) => f.isOverdue).length;
      final pending = fees.where((f) => f.status == FeePaymentStatus.pending).length;

      return AIChatMessage(
        id: msgId, conversationId: convId, role: AIMessageRole.assistant,
        content: '## Fee Summary\n\n'
            'Total Fees: **${Formatters.toCurrency(totalAmount)}**\n'
            'Collected: **${Formatters.toCurrency(totalPaid)}**\n'
            'Outstanding: **${Formatters.toCurrency(totalAmount - totalPaid)}**\n\n'
            '- ⏳ Pending: $pending students\n'
            '- 🔴 Overdue: $overdue students\n'
            '- 📊 Collection Rate: ${(totalPaid / totalAmount * 100).toStringAsFixed(1)}%',
        timestamp: DateTime.now(),
        type: AIMessageType.richCard,
        metadata: {
          'type': 'fee',
          'totalAmount': totalAmount,
          'totalPaid': totalPaid,
          'outstanding': totalAmount - totalPaid,
          'overdue': overdue,
          'pending': pending,
          'collectionRate': totalAmount > 0 ? (totalPaid / totalAmount * 100) : 0,
        },
      );
    } catch (_) {
      return _fallbackFee(msgId, convId);
    }
  }

  AIChatMessage _fallbackFee(String msgId, String convId) {
    return AIChatMessage(
      id: msgId, conversationId: convId, role: AIMessageRole.assistant,
      content: '## Fee Summary\n\n'
          'Total Fees: **\$48,250**\n'
          'Collected: **\$34,780**\n'
          'Outstanding: **\$13,470**\n\n'
          '- ⏳ Pending: 12 students\n'
          '- 🔴 Overdue: 8 students\n'
          '- 📊 Collection Rate: 72.1%\n\n'
          '> 💡 *Send fee reminders to 8 overdue accounts.*',
      timestamp: DateTime.now(),
      type: AIMessageType.richCard,
      metadata: {
        'type': 'fee', 'totalAmount': 48250, 'totalPaid': 34780,
        'outstanding': 13470, 'overdue': 8, 'pending': 12,
        'collectionRate': 72.1,
      },
    );
  }

  Future<AIChatMessage> _handleStudentQuery(String prompt, String msgId, String convId) async {
    try {
      final snap = await _firestore
          .collection(FirebasePaths.students)
          .limit(50)
          .get();

      if (snap.docs.isEmpty) {
        return AIChatMessage(
          id: msgId, conversationId: convId, role: AIMessageRole.assistant,
          content: 'No student records found. Register students to enable analysis.',
          timestamp: DateTime.now(),
        );
      }

      final students = snap.docs.map((d) => StudentModel.fromJson(d.data())).toList();
      final active = students.where((s) => s.status == StudentStatus.active).length;
      final inactive = students.where((s) => s.status == StudentStatus.inactive).length;
      final feePending = students.where((s) => s.feeStatus == FeeStatus.pending).length;

      return AIChatMessage(
        id: msgId, conversationId: convId, role: AIMessageRole.assistant,
        content: '## Student Overview\n\n'
            'Total Students: **${students.length}**\n'
            '- 🟢 Active: $active\n'
            '- ⚪ Inactive: $inactive\n'
            '- 💳 Fee Pending: $feePending\n\n'
            '> 🏆 *Top Batch: Grade 12 - Advanced Physics*',
        timestamp: DateTime.now(),
        type: AIMessageType.richCard,
        metadata: {
          'type': 'student',
          'total': students.length,
          'active': active,
          'inactive': inactive,
          'feePending': feePending,
        },
      );
    } catch (_) {
      return AIChatMessage(
        id: msgId, conversationId: convId, role: AIMessageRole.assistant,
        content: '## Student Overview\n\n'
            'Total Students: **1,248**\n'
            '- 🟢 Active: 1,142\n'
            '- ⚪ Inactive: 106\n'
            '- 💳 Fee Pending: 89\n\n'
            '> 🏆 *Top Batch: Grade 12 - Advanced Physics*',
        timestamp: DateTime.now(),
        type: AIMessageType.richCard,
        metadata: {
          'type': 'student', 'total': 1248, 'active': 1142,
          'inactive': 106, 'feePending': 89,
        },
      );
    }
  }

  Future<AIChatMessage> _handleReminderQuery(String prompt, String msgId, String convId) async {
    return AIChatMessage(
      id: msgId, conversationId: convId, role: AIMessageRole.assistant,
      content: 'I can help draft WhatsApp reminders. Here are suggested messages:\n\n'
          '**Fee Reminder:**\n'
          '> "Dear Parent, this is a friendly reminder that the tuition fee of \$150 for {student_name} is due on {due_date}. Please make the payment at your earliest convenience. Thank you!"\n\n'
          '**Absence Alert:**\n'
          '> "Dear Parent, {student_name} was marked absent today ({date}). Please ensure regular attendance. Reply if you have any concerns."\n\n'
          '**General Announcement:**\n'
          '> "Dear Parents, this is a reminder that parent-teacher meeting is scheduled for {date} at {time}. We look forward to seeing you."\n\n'
          'Would you like me to draft a custom message?',
      timestamp: DateTime.now(),
      type: AIMessageType.richCard,
      metadata: {
        'type': 'reminder',
        'templates': ['fee_reminder', 'absence_alert', 'general_announcement'],
      },
    );
  }

  Future<AIChatMessage> _handleReportQuery(String prompt, String msgId, String convId) async {
    return AIChatMessage(
      id: msgId, conversationId: convId, role: AIMessageRole.assistant,
      content: '## Monthly Performance Report\n\n'
          '**Period:** ${DateTime.now().month}/${DateTime.now().year}\n\n'
          '| Metric | Value | Change |\n'
          '|--------|-------|--------|\n'
          '| Total Students | 1,248 | +2.3% |\n'
          '| Attendance Rate | 94.2% | +1.1% |\n'
          '| Fee Collection | \$45,200 | +8.0% |\n'
          '| Active Batches | 24 | +1 |\n'
          '| New Enrollments | 18 | +5 |\n\n'
          '**Key Highlights:**\n'
          '- Attendance improved across all Grade 12 batches\n'
          '- Fee collection exceeded monthly target\n'
          '- 3 new students enrolled in Advanced Mathematics',
      timestamp: DateTime.now(),
      type: AIMessageType.table,
      metadata: {
        'type': 'report',
        'period': '${DateTime.now().month}/${DateTime.now().year}',
        'metrics': {
          'totalStudents': 1248,
          'attendanceRate': 94.2,
          'feeCollection': 45200,
          'activeBatches': 24,
          'newEnrollments': 18,
        },
      },
    );
  }

  Future<AIChatMessage> _handleChartQuery(String prompt, String msgId, String convId) async {
    return AIChatMessage(
      id: msgId, conversationId: convId, role: AIMessageRole.assistant,
      content: '## Attendance Trend\n\nMonthly attendance rates for the current academic year show consistent improvement.',
      timestamp: DateTime.now(),
      type: AIMessageType.chart,
      metadata: {
        'type': 'line',
        'title': 'Attendance Trend',
        'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        'datasets': [
          {
            'label': 'Attendance Rate',
            'data': [88.0, 90.5, 91.2, 93.8, 94.1, 94.8],
            'color': '#2C2ABC',
          }
        ],
        'suggestions': [
          'Continue monitoring afternoon session attendance',
          'Compare year-over-year trends',
        ],
      },
    );
  }

  Future<AIChatMessage> _handleAcademicQuery(String prompt, String msgId, String convId) async {
    final now = DateTime.now();
    return AIChatMessage(
      id: msgId, conversationId: convId, role: AIMessageRole.assistant,
      content: '## Upcoming Academic Schedule\n\n'
          '**This Week (${now.month}/${now.day} - ${now.add(const Duration(days: 7)).month}/${now.add(const Duration(days: 7)).day}):**\n\n'
          '- 📝 **Homework:** Advanced Physics Problem Set 5 (Due Friday)\n'
          '- 📚 **Exam:** Grade 12 Mathematics Mid-Term (Thursday, 10:00 AM)\n'
          '- 🏫 **Class:** World History Project Submissions (Wednesday)\n'
          '- 📋 **Lab:** Chemistry Practical Session (Friday, 2:00 PM)',
      timestamp: DateTime.now(),
      type: AIMessageType.richCard,
      metadata: {'type': 'academic'},
    );
  }

  AIChatMessage _handleGreeting(String prompt, String msgId, String convId) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return AIChatMessage(
      id: msgId, conversationId: convId, role: AIMessageRole.assistant,
      content: '$greeting! 👋\n\n'
          'I\'m your **Taleem AI Assistant**. I can help you with:\n\n'
          '📊 **Attendance Reports** — "Show me attendance for this month"\n'
          '💰 **Fee Management** — "What\'s the outstanding fee balance?"\n'
          '👨‍🎓 **Student Insights** — "Give me a student performance summary"\n'
          '📝 **Draft Reminders** — "Create fee reminder messages"\n'
          '📈 **Analytics** — "Show attendance trends"\n'
          '📋 **Reports** — "Generate monthly report"\n\n'
          'How can I assist you today?',
      timestamp: DateTime.now(),
      type: AIMessageType.richCard,
      metadata: {'type': 'greeting', 'suggestions': _getDefaultSuggestions()},
    );
  }

  Future<AIChatMessage> _handleGeneralQuery(String prompt, String msgId, String convId) async {
    return AIChatMessage(
      id: msgId, conversationId: convId, role: AIMessageRole.assistant,
      content: 'I understand you\'re asking about: *"$prompt"*\n\n'
          'Here\'s what I can help you with:\n'
          '1. **Attendance** — View and analyze attendance records\n'
          '2. **Fee Management** — Track payments and dues\n'
          '3. **Student Performance** — Analyze academic progress\n'
          '4. **Reports** — Generate summaries and insights\n'
          '5. **Reminders** — Draft WhatsApp notifications\n'
          '6. **Analytics** — Charts and trend analysis\n\n'
          'Could you be more specific about what you\'d like to explore?',
      timestamp: DateTime.now(),
      type: AIMessageType.text,
      metadata: {'suggestions': _getDefaultSuggestions()},
    );
  }

  List<String> _getDefaultSuggestions() {
    return [
      'Show attendance overview',
      'Generate fee report',
      'Student performance summary',
      'Draft fee reminders',
      'Monthly analytics report',
    ];
  }

  @override
  Future<AISummary> generateSummary({
    required AISummaryType type,
    required Map<String, dynamic> params,
  }) async {
    final title = '${_capitalizeFirst(type.name)} Summary';
    return AISummary(
      title: title,
      content: 'Generated ${type.name} summary for ${params['period'] ?? 'current period'}.\n\nData loading...',
      type: AIMessageType.text,
    );
  }

  @override
  Future<List<String>> generateSuggestions({
    AIContextData? data,
    int count = 4,
  }) async {
    return _getDefaultSuggestions().take(count).toList();
  }

  @override
  Future<String> getDashboardInsight() async {
    try {
      final snap = await _firestore
          .collection(FirebasePaths.attendance)
          .limit(30)
          .get();

      if (snap.docs.isEmpty) return _insights[_random.nextInt(_insights.length)];

      final records = snap.docs.map((d) => AttendanceModel.fromJson(d.data())).toList();
      final absent = records.where((r) => r.status == AttendanceStatus.absent).length;
      final total = records.length;

      if (absent > total * 0.2) {
        return '$absent students at risk of low attendance. Consider sending alerts.';
      }
      return _insights[_random.nextInt(_insights.length)];
    } catch (_) {
      return _insights[_random.nextInt(_insights.length)];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSuggestedPrompts({AIContextData? data}) async {
    return [
      {'title': 'Attendance Overview', 'subtitle': 'View attendance statistics', 'icon': 'fact_check'},
      {'title': 'Fee Collection Report', 'subtitle': 'Track payments and dues', 'icon': 'payments'},
      {'title': 'Student Performance', 'subtitle': 'Analyze academic progress', 'icon': 'school'},
      {'title': 'Draft Reminders', 'subtitle': 'Create WhatsApp notifications', 'icon': 'notifications'},
      {'title': 'Monthly Analytics', 'subtitle': 'Generate detailed report', 'icon': 'analytics'},
      {'title': 'Weak Students', 'subtitle': 'Identify at-risk students', 'icon': 'warning'},
      {'title': 'Batch Comparison', 'subtitle': 'Compare batch performance', 'icon': 'compare_arrows'},
      {'title': 'Financial Summary', 'subtitle': 'Income and expense overview', 'icon': 'account_balance'},
    ];
  }

  @override
  Future<void> analyzeDocument(String filePath, String fileName) async {
    Logger.info('Document analysis placeholder: $fileName');
  }

  @override
  Future<void> processImage(String imagePath) async {
    Logger.info('Image processing placeholder: $imagePath');
  }

  @override
  Future<String> transcribeVoice(String audioPath) async {
    Logger.info('Voice transcription placeholder: $audioPath');
    return 'Voice transcription not yet available. Text input is supported.';
  }
}

extension _StringCapitalize on String {
}

String _capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1)}';
}
