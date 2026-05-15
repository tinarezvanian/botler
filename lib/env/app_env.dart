import 'package:flutter/foundation.dart';

import 'env_loader_stub.dart'
    if (dart.library.io) 'env_loader_io.dart' as env_loader;

/// Loads secrets and API-related settings from `.env.local` (IO platforms).
/// `--dart-define=KEY=value` overrides the file when non-empty.
class AppEnv {
  AppEnv._();

  static Map<String, String> _file = {};

  static Future<void> init() async {
    if (kIsWeb) {
      _file = {};
      return;
    }
    _file = await env_loader.loadEnvLocalFile();
  }

  static String _fromFile(String key, [String fallback = '']) {
    final v = _file[key];
    if (v != null && v.trim().isNotEmpty) return v.trim();
    return fallback;
  }

  static String get openAiApiKey {
    const v = String.fromEnvironment('OPENAI_API_KEY');
    if (v.isNotEmpty) return v;
    return _fromFile('OPENAI_API_KEY');
  }

  static String get openAiModel {
    const v = String.fromEnvironment('OPENAI_MODEL');
    if (v.isNotEmpty) return v;
    return _fromFile('OPENAI_MODEL', 'text-davinci-003');
  }

  static String get openAiApiHost {
    const v = String.fromEnvironment('OPENAI_API_HOST');
    if (v.isNotEmpty) return v;
    return _fromFile('OPENAI_API_HOST', 'api.openai.com');
  }

  static String get openAiCompletionsPath {
    const v = String.fromEnvironment('OPENAI_COMPLETIONS_PATH');
    if (v.isNotEmpty) return v;
    return _fromFile('OPENAI_COMPLETIONS_PATH', '/v1/completions');
  }

  static Uri get openAiCompletionsUri =>
      Uri.https(openAiApiHost, openAiCompletionsPath);

  static double get openAiTemperature {
    const v = String.fromEnvironment('OPENAI_TEMPERATURE');
    if (v.isNotEmpty) return double.tryParse(v) ?? 1;
    return double.tryParse(_fromFile('OPENAI_TEMPERATURE', '1')) ?? 1;
  }

  static int get openAiMaxTokens {
    const v = String.fromEnvironment('OPENAI_MAX_TOKENS');
    if (v.isNotEmpty) return int.tryParse(v) ?? 2000;
    return int.tryParse(_fromFile('OPENAI_MAX_TOKENS', '2000')) ?? 2000;
  }

  static double get openAiTopP {
    const v = String.fromEnvironment('OPENAI_TOP_P');
    if (v.isNotEmpty) return double.tryParse(v) ?? 1;
    return double.tryParse(_fromFile('OPENAI_TOP_P', '1')) ?? 1;
  }

  static double get openAiFrequencyPenalty {
    const v = String.fromEnvironment('OPENAI_FREQUENCY_PENALTY');
    if (v.isNotEmpty) return double.tryParse(v) ?? 0;
    return double.tryParse(_fromFile('OPENAI_FREQUENCY_PENALTY', '0')) ?? 0;
  }

  static double get openAiPresencePenalty {
    const v = String.fromEnvironment('OPENAI_PRESENCE_PENALTY');
    if (v.isNotEmpty) return double.tryParse(v) ?? 0;
    return double.tryParse(_fromFile('OPENAI_PRESENCE_PENALTY', '0')) ?? 0;
  }
}
