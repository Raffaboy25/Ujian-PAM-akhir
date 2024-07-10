import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../services/api_service.dart';

part 'player_data.g.dart';

// This class stores the player progress persistently.
@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(1)
  int highScore = 0;

  final ApiService _apiService;

  PlayerData(this._apiService) {
    _loadHighScore();
  }

  int _lives = 5;

  int get lives => _lives;
  set lives(int value) {
    if (value <= 5 && value >= 0) {
      _lives = value;
      notifyListeners();
    }
  }

  int _currentScore = 0;

  int get currentScore => _currentScore;
  set currentScore(int value) {
    _currentScore = value;

    if (highScore < _currentScore) {
      highScore = _currentScore;
      saveHighScore();
    }

    notifyListeners();
    save();
  }

  void _loadHighScore() async {
    try {
      highScore = await _apiService.loadHighScore();
    } catch (e) {
      final box = await Hive.openBox('playerDataBox');
      highScore = box.get('highScore', defaultValue: 0);
    }
    notifyListeners();
  }

  void saveHighScore() async {
    try {
      await _apiService.saveHighScore(highScore);
    } catch (e) {
      // Handle error saving to API
    }
    final box = await Hive.openBox('playerDataBox');
    box.put('highScore', highScore);
  }
}
