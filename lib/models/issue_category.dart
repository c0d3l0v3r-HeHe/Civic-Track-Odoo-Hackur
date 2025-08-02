import 'package:flutter/material.dart';

enum IssueCategory {
  roads('Roads', 'Potholes, obstructions', Icons.route, Color(0xFF667eea)),
  lighting(
    'Lighting',
    'Broken or flickering lights',
    Icons.lightbulb_outline,
    Color(0xFFFFB347),
  ),
  waterSupply(
    'Water Supply',
    'Leaks, low pressure',
    Icons.water_drop,
    Color(0xFF2196F3),
  ),
  cleanliness(
    'Cleanliness',
    'Overflowing bins, garbage',
    Icons.cleaning_services,
    Color(0xFF51C878),
  ),
  publicSafety(
    'Public Safety',
    'Open manholes, exposed wiring',
    Icons.security,
    Color(0xFFFF6B6B),
  ),
  obstructions(
    'Obstructions',
    'Fallen trees, debris',
    Icons.block,
    Color(0xFF9B59B6),
  );

  const IssueCategory(
    this.displayName,
    this.description,
    this.icon,
    this.color,
  );

  final String displayName;
  final String description;
  final IconData icon;
  final Color color;

  // Get category by name
  static IssueCategory? fromString(String name) {
    try {
      return IssueCategory.values.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get all categories as a list for dropdowns
  static List<IssueCategory> getAllCategories() {
    return IssueCategory.values;
  }

  // Get urgent categories (for priority filtering)
  static List<IssueCategory> getUrgentCategories() {
    return [
      IssueCategory.publicSafety,
      IssueCategory.roads,
      IssueCategory.waterSupply,
      IssueCategory.lighting,
    ];
  }

  // Check if category is urgent
  bool get isUrgent {
    return getUrgentCategories().contains(this);
  }

  // Get light version of the color for backgrounds
  Color get lightColor {
    return color.withOpacity(0.1);
  }

  // Get category emoji for fun display
  String get emoji {
    switch (this) {
      case IssueCategory.roads:
        return '🛣️';
      case IssueCategory.lighting:
        return '�';
      case IssueCategory.waterSupply:
        return '💧';
      case IssueCategory.cleanliness:
        return '�️';
      case IssueCategory.publicSafety:
        return '🚨';
      case IssueCategory.obstructions:
        return '🚧';
    }
  }

  @override
  String toString() => displayName;
}
