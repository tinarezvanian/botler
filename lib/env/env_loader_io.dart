import 'dart:io';

Future<Map<String, String>> loadEnvLocalFile() async {
  final file = File('.env.local');
  if (!await file.exists()) return {};
  final raw = await file.readAsString();
  return _parseDotEnv(raw);
}

Map<String, String> _parseDotEnv(String content) {
  final map = <String, String>{};
  for (final line in content.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final eq = trimmed.indexOf('=');
    if (eq <= 0) continue;
    final key = trimmed.substring(0, eq).trim();
    if (key.isEmpty) continue;
    var value = trimmed.substring(eq + 1).trim();
    if (value.length >= 2) {
      final q = value[0];
      if ((q == '"' || q == "'") && value[value.length - 1] == q) {
        value = value.substring(1, value.length - 1);
      }
    }
    map[key] = value;
  }
  return map;
}
