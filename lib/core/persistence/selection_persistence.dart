import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/content_filter_provider.dart';

/// EN: Handles persisting lightweight selection data across the app.
/// KO: 앱 전반에서 사용되는 선택 정보를 영구 저장합니다.
class SelectionPersistence {
  /// EN: Creates the persistence helper with dependencies.
  /// KO: 필요한 의존성과 함께 지속성 도우미를 생성합니다.
  SelectionPersistence({
    required SharedPreferences preferences,
    required Ref ref,
  })  : _preferences = preferences,
        _ref = ref;

  final SharedPreferences _preferences;
  final Ref _ref;

  static const _projectKey = 'selected_project';
  static const _bandKey = 'selected_band';

  /// EN: Restores the previously selected project/band and begins watching for changes.
  /// KO: 이전에 선택된 프로젝트/밴드를 복원하고 변경 사항을 감시합니다.
  Future<void> initialize() async {
    final savedProject = _preferences.getString(_projectKey);
    final savedBand = _preferences.getString(_bandKey);

    final currentProject = _ref.read(selectedProjectProvider);
    final currentBand = _ref.read(selectedBandProvider);

    if (currentProject == null && savedProject != null) {
      _ref.read(selectedProjectProvider.notifier).state = savedProject;
    }

    if (currentBand == null && savedBand != null) {
      _ref.read(selectedBandProvider.notifier).state = savedBand;
    }

    _ref.listen<String?>(selectedProjectProvider, (previous, next) async {
      if (next == null) {
        await _preferences.remove(_projectKey);
      } else {
        await _preferences.setString(_projectKey, next);
      }
    });

    _ref.listen<String?>(selectedBandProvider, (previous, next) async {
      if (next == null) {
        await _preferences.remove(_bandKey);
      } else {
        await _preferences.setString(_bandKey, next);
      }
    });
  }

  /// EN: Stores arbitrary JSON-serializable selection data under a key.
  /// KO: 임의의 JSON 직렬화 가능한 선택 데이터를 키로 저장합니다.
  Future<void> saveSelection(String key, Object? value) async {
    if (value == null) {
      await _preferences.remove(key);
      return;
    }

    await _preferences.setString(key, jsonEncode(value));
  }

  /// EN: Reads previously stored selection data.
  /// KO: 이전에 저장된 선택 데이터를 읽어옵니다.
  Future<dynamic> getSelection(String key) async {
    final raw = _preferences.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  /// EN: Removes a stored selection entry.
  /// KO: 저장된 선택 데이터를 제거합니다.
  Future<void> clearSelection(String key) async {
    await _preferences.remove(key);
  }
}
