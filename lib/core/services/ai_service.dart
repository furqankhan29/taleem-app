import 'package:get/get.dart';
import 'package:taleem/data/models/ai_chat_message_model.dart';

enum AISummaryType {
  attendance,
  fee,
  student,
  batch,
  teacher,
  financial,
  performance,
  custom;
}

class AIContextData {
  final String? userId;
  final String? batchId;
  final String? studentId;
  final Map<String, dynamic>? filters;
  final DateTime? startDate;
  final DateTime? endDate;

  const AIContextData({
    this.userId,
    this.batchId,
    this.studentId,
    this.filters,
    this.startDate,
    this.endDate,
  });
}

class AISummary {
  final String title;
  final String content;
  final AIMessageType type;
  final Map<String, dynamic>? metadata;

  const AISummary({
    required this.title,
    required this.content,
    this.type = AIMessageType.text,
    this.metadata,
  });
}

abstract class BaseAIService extends GetxService {
  Future<AIChatMessage> generateResponse({
    required String prompt,
    required List<AIChatMessage> context,
    AIContextData? data,
  });

  Future<AISummary> generateSummary({
    required AISummaryType type,
    required Map<String, dynamic> params,
  });

  Future<List<String>> generateSuggestions({
    AIContextData? data,
    int count = 4,
  });

  Future<String> getDashboardInsight();

  Future<List<Map<String, dynamic>>> getSuggestedPrompts({AIContextData? data});

  Future<void> analyzeDocument(String filePath, String fileName);
  Future<void> processImage(String imagePath);
  Future<String> transcribeVoice(String audioPath);
}

class AIServiceConfig {
  static const String providerOpenAI = 'openai';
  static const String providerGemini = 'gemini';
  static const String providerClaude = 'claude';
  static const String providerLocal = 'local';

  static String activeProvider = providerLocal;

  static const Map<String, String> apiKeys = {
    providerOpenAI: '',
    providerGemini: '',
    providerClaude: '',
  };

  static const Map<String, String> modelNames = {
    providerOpenAI: 'gpt-4',
    providerGemini: 'gemini-pro',
    providerClaude: 'claude-3-opus',
  };
}
