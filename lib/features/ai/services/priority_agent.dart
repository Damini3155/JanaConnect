import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:geo_tag_camera/core/constants/api_constants.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';

class PriorityResult {
  final String priority;
  final int severityScore;
  final String reasoning;

  const PriorityResult({
    required this.priority,
    required this.severityScore,
    required this.reasoning,
  });
}

/// Agent 2: AI Priority Assessment Agent
class PriorityAgent {
  /// Assess priority level (low, medium, high, critical) and severity score (1-10)
  Future<PriorityResult> assessPriority({
    required String category,
    required String description,
    required String imagePath,
  }) async {
    if (ApiConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return _fallbackPriority(category, description);
    }

    try {
      final model = GenerativeModel(
        model: ApiConstants.geminiModel,
        apiKey: ApiConstants.geminiApiKey,
      );

      final prompt = Content.multi([
        TextPart('${ApiConstants.priorityPrompt}\nCategory: "$category"\nDescription: "$description"'),
        if (imagePath.isNotEmpty && File(imagePath).existsSync())
          DataPart('image/jpeg', await File(imagePath).readAsBytes()),
      ]);

      final response = await model.generateContent([prompt]);
      final text = response.text ?? '';

      final jsonStr = _extractJson(text);
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        return PriorityResult(
          priority: data['priority'] as String? ?? ComplaintPriority.medium,
          severityScore: (data['severityScore'] as num?)?.toInt() ?? 6,
          reasoning: data['reasoning'] as String? ?? 'Evaluated via Gemini Priority Agent',
        );
      }
    } catch (e) {
      debugPrint('PriorityAgent error: $e');
    }

    return _fallbackPriority(category, description);
  }

  PriorityResult _fallbackPriority(String category, String desc) {
    final lower = desc.toLowerCase();
    if (lower.contains('urgent') || lower.contains('danger') || lower.contains('hazard') || lower.contains('accident') || lower.contains('fire')) {
      return const PriorityResult(priority: ComplaintPriority.critical, severityScore: 9, reasoning: 'Public safety hazard detected');
    } else if (category == ComplaintCategory.waterLeakage || category == ComplaintCategory.roadDamage) {
      return const PriorityResult(priority: ComplaintPriority.high, severityScore: 7, reasoning: 'Infrastructure risk');
    } else if (category == ComplaintCategory.garbageWaste || category == ComplaintCategory.streetlight) {
      return const PriorityResult(priority: ComplaintPriority.medium, severityScore: 5, reasoning: 'Standard civic issue');
    }
    return const PriorityResult(priority: ComplaintPriority.low, severityScore: 3, reasoning: 'Minor maintenance request');
  }

  String? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return null;
  }
}
