import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  GenerativeModel? _model;

  void initialize(String apiKey) {
    if (apiKey.isEmpty) return;
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  bool get isInitialized => _model != null;

  Future<String> getSuggestion(String prompt) async {
    if (_model == null) return "AI not initialized. Please provide an API key in Agent Mode.";
    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text ?? "No response.";
    } catch (e) {
      return "Error communicating with AI: $e";
    }
  }
}
