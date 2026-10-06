/// API endpoint and key constants.
/// Replace placeholder values with your actual keys before running.
class ApiConstants {
  ApiConstants._();

  // ── Google Gemini AI ───────────────────────────────────────────────────────
  /// TODO: Replace with your Gemini API key from https://aistudio.google.com/
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
  );

  static const String geminiModel = 'gemini-2.0-flash';

  // ── Google Maps ────────────────────────────────────────────────────────────
  /// TODO: Replace with your Google Maps API key from Google Cloud Console
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  // ── AI Prompts ─────────────────────────────────────────────────────────────
  static const String classificationPrompt = '''
You are an AI assistant for a Municipal Complaint Management System.
Analyze the provided image and complaint description, then classify the complaint.

Return a JSON response with exactly this structure:
{
  "category": "<one of: garbage_waste, road_damage, water_leakage, drainage_problem, streetlight, illegal_dumping, public_property, tree_environment, animal_related, other>",
  "confidence": <float between 0.0 and 1.0>,
  "description": "<brief 1-sentence explanation>"
}

Only return valid JSON. No markdown, no extra text.
''';

  static const String priorityPrompt = '''
You are an AI assistant for a Municipal Complaint Management System.
Based on the complaint category, description, and image, determine the priority level.

Consider:
- Public safety risk
- Severity of the issue
- Potential for escalation

Return a JSON response with exactly this structure:
{
  "priority": "<one of: low, medium, high, critical>",
  "severityScore": <integer 1-10>,
  "reasoning": "<brief 1-sentence explanation>"
}

Only return valid JSON. No markdown, no extra text.
''';
}
