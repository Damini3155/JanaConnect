import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:geo_tag_camera/core/constants/api_constants.dart';
import 'package:geo_tag_camera/core/constants/app_constants.dart';

class ClassificationResult {
  final String category;
  final double confidence;
  final String reasoning;

  const ClassificationResult({
    required this.category,
    required this.confidence,
    required this.reasoning,
  });
}

/// Agent 1: AI Complaint Classification Agent
class ClassificationAgent {
  /// Classify complaint based on photo and description using Gemini multimodal model
  Future<ClassificationResult> classify({
    required String imagePath,
    required String description,
  }) async {
    // If Gemini API key is placeholder, use rule-based fallback
    if (ApiConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return _fallbackClassification(description);
    }

    try {
      final model = GenerativeModel(
        model: ApiConstants.geminiModel,
        apiKey: ApiConstants.geminiApiKey,
      );

      final prompt = Content.multi([
        TextPart('${ApiConstants.classificationPrompt}\nComplaint Description: "$description"'),
        if (imagePath.isNotEmpty && File(imagePath).existsSync())
          DataPart('image/jpeg', await File(imagePath).readAsBytes()),
      ]);

      final response = await model.generateContent([prompt]);
      final text = response.text ?? '';

      final jsonStr = _extractJson(text);
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        return ClassificationResult(
          category: data['category'] as String? ?? ComplaintCategory.other,
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.85,
          reasoning: data['description'] as String? ?? 'Classified via Gemini Vision',
        );
      }
    } catch (e) {
      debugPrint('ClassificationAgent error: $e');
    }

    return _fallbackClassification(description);
  }

  ClassificationResult _fallbackClassification(String desc) {
    final lower = desc.toLowerCase();
    if (lower.contains('garbage') || lower.contains('trash') || lower.contains('waste') || lower.contains('dump')) {
      return const ClassificationResult(category: ComplaintCategory.garbageWaste, confidence: 0.90, reasoning: 'Waste keywords detected');
    } else if (lower.contains('pothole') || lower.contains('road') || lower.contains('crack') || lower.contains('asphalt')) {
      return const ClassificationResult(category: ComplaintCategory.roadDamage, confidence: 0.92, reasoning: 'Road keywords detected');
    } else if (lower.contains('water') || lower.contains('pipe') || lower.contains('leak') || lower.contains('overflow')) {
      return const ClassificationResult(category: ComplaintCategory.waterLeakage, confidence: 0.88, reasoning: 'Water leak keywords detected');
    } else if (lower.contains('light') || lower.contains('lamp') || lower.contains('dark') || lower.contains('electric')) {
      return const ClassificationResult(category: ComplaintCategory.streetlight, confidence: 0.89, reasoning: 'Light keywords detected');
    } else if (lower.contains('drain') || lower.contains('sewage') || lower.contains('gutter')) {
      return const ClassificationResult(category: ComplaintCategory.drainageProblem, confidence: 0.87, reasoning: 'Drainage keywords detected');
    }
    return const ClassificationResult(category: ComplaintCategory.other, confidence: 0.75, reasoning: 'General civic complaint');
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
