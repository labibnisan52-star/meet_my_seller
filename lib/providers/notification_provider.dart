import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 3; // Mock initial state

  int get unreadCount => _unreadCount;

  void markAllAsRead() {
    _unreadCount = 0;
    notifyListeners();
  }

  void addNotification() {
    _unreadCount++;
    notifyListeners();
  }
}
