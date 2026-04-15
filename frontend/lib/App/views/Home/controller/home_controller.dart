import 'dart:async';
import 'package:flutter/material.dart';

class HomeController with ChangeNotifier {
  int selectedTab = 0;
  int feedbackRating = 4;

  Timer? subscriptionTimer;

  final tabs = ["Today", "Week", "Month"];

  void changeTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  void updateRating(int rating) {
    feedbackRating = rating;
    notifyListeners();
  }

  void startSubscriptionTimer(VoidCallback callback) {
    subscriptionTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => callback(),
    );
  }

  void disposeController() {
    subscriptionTimer?.cancel();
  }
}
