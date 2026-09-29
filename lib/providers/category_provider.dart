import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final List<String> _categories = [
    'Electronics',
    'Mobile Phones',
    'Clothing',
    'Home & Garden',
    'Automotive',
    'Industrial',
  ];

  List<String> get categories => List.unmodifiable(_categories);

  /// Adds a new category if it doesn't already exist (case-insensitive check)
  /// Returns null if successful, or an error message if invalid.
  String? addCategory(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Category name cannot be empty.';
    }

    final exists = _categories.any((c) => c.toLowerCase() == trimmedName.toLowerCase());
    if (exists) {
      return 'Category already exists.';
    }

    _categories.add(trimmedName);
    notifyListeners();
    return null; // Success
  }
}
