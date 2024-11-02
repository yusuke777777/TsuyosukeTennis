import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  void loadNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _notificationCount = prefs.getInt('notification_count') ?? 0;
    notifyListeners();
  }

  void increment() {
    _notificationCount++;
    notifyListeners();
  }

  void reset() {
    _notificationCount = 0;
    notifyListeners();
  }
}
