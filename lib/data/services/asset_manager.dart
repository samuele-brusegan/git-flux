import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flux_git/data/models/user_preferences.dart';

/// Metadata describing a single Academy lesson bundled as an asset.
class AcademyLesson {
  final String id;
  final String title;
  final String description;
  final String file;
  final SkillLevel minLevel;

  const AcademyLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.file,
    required this.minLevel,
  });

  factory AcademyLesson.fromJson(Map<String, dynamic> json) {
    return AcademyLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      file: json['file'] as String,
      minLevel: SkillLevel.values.byName(
        (json['minLevel'] as String?) ?? 'beginner',
      ),
    );
  }
}

/// Lazily loads Academy lessons and their markdown content from bundled assets.
class AssetManager {
  static const _basePath = 'assets/academy';

  List<AcademyLesson>? _cachedIndex;
  final Map<String, String> _contentCache = {};

  /// Loads (and caches) the lesson index.
  Future<List<AcademyLesson>> loadLessons() async {
    if (_cachedIndex != null) return _cachedIndex!;
    final raw = await rootBundle.loadString('$_basePath/index.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => AcademyLesson.fromJson(e as Map<String, dynamic>))
        .toList();
    _cachedIndex = list;
    return list;
  }

  /// Loads (and caches) the markdown content for [lesson].
  Future<String> loadContent(AcademyLesson lesson) async {
    final cached = _contentCache[lesson.id];
    if (cached != null) return cached;
    final content = await rootBundle.loadString('$_basePath/${lesson.file}');
    _contentCache[lesson.id] = content;
    return content;
  }
}
