import 'package:flutter/foundation.dart';
import 'package:geo_tag_camera/features/ai/services/classification_agent.dart';
import 'package:geo_tag_camera/features/ai/services/priority_agent.dart';
import 'package:geo_tag_camera/features/ai/services/duplicate_agent.dart';
import 'package:geo_tag_camera/features/ai/services/routing_agent.dart';
import 'package:geo_tag_camera/features/complaints/models/complaint_model.dart';

/// Master AI Orchestrator running all 4 agents sequentially.
class AIOrchestrator {
  final ClassificationAgent _classificationAgent = ClassificationAgent();
  final PriorityAgent _priorityAgent = PriorityAgent();
  final DuplicateAgent _duplicateAgent = DuplicateAgent();
  final RoutingAgent _routingAgent = RoutingAgent();

  /// Execute AI Multi-Agent analysis on a submitted complaint
  Future<AIAnalysisResult> analyzeComplaint({
    required String imagePath,
    required String description,
    required double latitude,
    required double longitude,
    required List<ComplaintModel> existingComplaints,
  }) async {
    debugPrint('🤖 AI Orchestrator: Initiating 4-Agent Pipeline...');

    // Agent 1: Classification
    final classification = await _classificationAgent.classify(
      imagePath: imagePath,
      description: description,
    );
    debugPrint('🤖 Agent 1 (Classification): Category=${classification.category}, Confidence=${classification.confidence}');

    // Agent 2: Priority
    final priority = await _priorityAgent.assessPriority(
      category: classification.category,
      description: description,
      imagePath: imagePath,
    );
    debugPrint('🤖 Agent 2 (Priority): Level=${priority.priority}, SeverityScore=${priority.severityScore}');

    // Agent 3: Duplicate Detection
    final duplicate = _duplicateAgent.detectDuplicate(
      latitude: latitude,
      longitude: longitude,
      category: classification.category,
      existingComplaints: existingComplaints,
    );
    debugPrint('🤖 Agent 3 (Duplicate): isDuplicate=${duplicate.isDuplicate}, Probability=${duplicate.duplicateProbability}');

    // Agent 4: Routing
    final routing = _routingAgent.routeComplaint(
      category: classification.category,
      priority: priority.priority,
    );
    debugPrint('🤖 Agent 4 (Routing): Department=${routing.department}');

    return AIAnalysisResult(
      category: classification.category,
      confidence: classification.confidence,
      priority: priority.priority,
      severityScore: priority.severityScore,
      duplicateProbability: duplicate.duplicateProbability,
      recommendedDepartment: routing.department,
      isDuplicate: duplicate.isDuplicate,
      linkedComplaintId: duplicate.linkedComplaintId,
    );
  }
}
