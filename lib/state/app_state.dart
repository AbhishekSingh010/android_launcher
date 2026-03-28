import 'dart:async';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

enum AppMode { calm, focus, aggressive }

class AppState extends ChangeNotifier {
  final AIService aiService = AIService();

  List<Application> _installedApps = [];
  List<Application> get installedApps => _installedApps;

  String _geminiApiKey = '';
  String get geminiApiKey => _geminiApiKey;

  AppMode _currentMode = AppMode.calm;
  AppMode get currentMode => _currentMode;

  // Focus Timer
  int _focusTimeRemaining = 0;
  Timer? _focusTimer;
  bool get isFocusTimerRunning => _focusTimer != null && _focusTimer!.isActive;
  int get focusTimeRemaining => _focusTimeRemaining;

  // Tasks (Mock Mission Control)
  List<String> _tasks = ['Complete Mission Briefing', 'Review Objective Beta', 'Synchronize Data'];
  List<String> get tasks => _tasks;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await _loadApiKey();
    await _loadApps();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _geminiApiKey = prefs.getString('gemini_api_key') ?? '';
    if (_geminiApiKey.isNotEmpty) {
      aiService.initialize(_geminiApiKey);
    }
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _geminiApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    aiService.initialize(key);
    notifyListeners();
  }

  Future<void> _loadApps() async {
    try {
      _installedApps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true,
      );
      _installedApps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading apps: $e");
    }
  }

  void launchApp(String packageName) {
    DeviceApps.openApp(packageName);
  }

  void setMode(AppMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  // Timer logic
  void startFocusTimer(int minutes) {
    _focusTimeRemaining = minutes * 60;
    setMode(AppMode.focus);
    _focusTimer?.cancel();
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_focusTimeRemaining > 0) {
        _focusTimeRemaining--;
        notifyListeners();
      } else {
        stopFocusTimer();
      }
    });
    notifyListeners();
  }

  void stopFocusTimer() {
    _focusTimer?.cancel();
    _focusTimeRemaining = 0;
    setMode(AppMode.calm);
    notifyListeners();
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  void addTask(String task) {
    _tasks.add(task);
    notifyListeners();
  }
}
