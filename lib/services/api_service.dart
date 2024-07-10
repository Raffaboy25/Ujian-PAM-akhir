import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<void> saveHighScore(int score) async {
    final response = await http.post(
      Uri.parse('$baseUrl/highscore'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'highScore': score}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save high score');
    }
  }

  Future<int> loadHighScore() async {
    final response = await http.get(
      Uri.parse('$baseUrl/highscore'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['highScore'] ?? 0;
    } else {
      throw Exception('Failed to load high score');
    }
  }
}
