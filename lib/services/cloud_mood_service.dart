import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mood_result.dart';
import 'ai_provider_service.dart';
import 'image_preprocessor.dart';

/// Classifies a photo's mood with a hosted vision model (Gemini or OpenAI).
class CloudMoodService {
  CloudMoodService._();
  static final instance = CloudMoodService._();

  static final _prompt = 'Classify the overall mood/atmosphere of this photo. '
      'Reply with JSON only: an object with exactly these keys, each a '
      'probability between 0 and 1, summing to 1: '
      '${MoodLabel.values.map((m) => m.name).join(', ')}.';

  Future<MoodResult> classify(
    AiProvider provider,
    String apiKey,
    String imagePath,
  ) async {
    final watch = Stopwatch()..start();
    final b64 = base64Encode(await encodeForUpload(imagePath));

    final text = switch (provider) {
      AiProvider.gemini => await _gemini(apiKey, b64),
      AiProvider.openai => await _openai(apiKey, b64),
    };

    final probs = _parse(text);
    var best = 0;
    for (var i = 1; i < probs.length; i++) {
      if (probs[i] > probs[best]) best = i;
    }
    return MoodResult(
      label: MoodLabel.values[best],
      confidence: probs[best],
      embedding: probs,
      timestamp: DateTime.now(),
      inferenceTimeMs: watch.elapsedMilliseconds,
    );
  }

  Future<String> _gemini(String key, String b64) async {
    final res = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-2.5-flash:generateContent',
      ),
      headers: {'x-goog-api-key': key, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _prompt},
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': b64},
              },
            ],
          },
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      }),
    );
    final body = _ok(res);
    return body['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  Future<String> _openai(String key, String b64) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': _prompt},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$b64'},
              },
            ],
          },
        ],
      }),
    );
    final body = _ok(res);
    return body['choices'][0]['message']['content'] as String;
  }

  Map<String, dynamic> _ok(http.Response res) {
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('API key rejected (${res.statusCode}). Sign in again.');
    }
    if (res.statusCode != 200) {
      throw Exception('Provider error ${res.statusCode}.');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// JSON text -> probabilities in [MoodLabel] order, renormalized.
  /// Throws [FormatException] if the reply isn't usable.
  List<double> _parse(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    final probs = [
      for (final m in MoodLabel.values)
        ((json[m.name] as num?) ?? 0).toDouble(),
    ];
    final sum = probs.fold<double>(0, (a, b) => a + b);
    if (sum <= 0) throw const FormatException('Model returned no mood scores');
    return [for (final p in probs) p / sum];
  }
}
