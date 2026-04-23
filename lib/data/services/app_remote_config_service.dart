// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppRemoteConfig {
  static const String defaultFeedbackUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSd3NmQZyROb7Z_tnULmbJuBEJpOW02_EjcIRNBRVLsKF7lFHQ/viewform?usp=publish-editor';

  final bool homeFeedbackEnabled;
  final String? homeFeedbackUrl;
  final String? latestVersion;
  final String? minimumSupportedVersion;

  const AppRemoteConfig({
    required this.homeFeedbackEnabled,
    required this.homeFeedbackUrl,
    this.latestVersion,
    this.minimumSupportedVersion,
  });

  factory AppRemoteConfig.defaults() {
    return const AppRemoteConfig(
      homeFeedbackEnabled: true,
      homeFeedbackUrl: defaultFeedbackUrl,
      latestVersion: null,
      minimumSupportedVersion: null,
    );
  }

  factory AppRemoteConfig.fromJson(Map<String, dynamic> json) {
    final feedbackEnabled = json['homeFeedbackEnabled'];
    final feedbackUrl = json['homeFeedbackUrl'];

    return AppRemoteConfig(
      homeFeedbackEnabled: feedbackEnabled is bool
          ? feedbackEnabled
          : AppRemoteConfig.defaults().homeFeedbackEnabled,
      homeFeedbackUrl: feedbackUrl is String && feedbackUrl.trim().isNotEmpty
          ? feedbackUrl.trim()
          : null,
      latestVersion: _asCleanString(json['latestVersion']),
      minimumSupportedVersion: _asCleanString(json['minimumSupportedVersion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homeFeedbackEnabled': homeFeedbackEnabled,
      'homeFeedbackUrl': homeFeedbackUrl,
      'latestVersion': latestVersion,
      'minimumSupportedVersion': minimumSupportedVersion,
    };
  }

  static String? _asCleanString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class AppRemoteConfigService {
  static const String _remoteConfigUrl =
      'https://raw.githubusercontent.com/vicajilau/quizdy/main/app_config.json';
  static const String _cachePayloadKey = 'remote_app_config_payload';
  static const String _cacheTimestampKey = 'remote_app_config_timestamp_ms';
  static const Duration _cacheTtl = Duration(hours: 6);

  final SharedPreferences _sharedPreferences;

  AppRemoteConfigService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  Future<AppRemoteConfig> getConfig({bool forceRefresh = false}) async {
    final cachedConfig = _readCachedConfig();

    if (!forceRefresh && _isCacheValid()) {
      if (cachedConfig != null) return cachedConfig;
      return AppRemoteConfig.defaults();
    }

    try {
      final remoteConfig = await _fetchRemoteConfig();
      await _writeCache(remoteConfig);
      return remoteConfig;
    } catch (_) {
      if (cachedConfig != null) return cachedConfig;
      return AppRemoteConfig.defaults();
    }
  }

  Future<AppRemoteConfig> refreshConfig() {
    return getConfig(forceRefresh: true);
  }

  bool _isCacheValid() {
    final fetchedAtMs = _sharedPreferences.getInt(_cacheTimestampKey);
    if (fetchedAtMs == null) return false;

    final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtMs);
    final age = DateTime.now().difference(fetchedAt);
    return age <= _cacheTtl;
  }

  AppRemoteConfig? _readCachedConfig() {
    final payload = _sharedPreferences.getString(_cachePayloadKey);
    if (payload == null || payload.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(payload) as Map<String, dynamic>;
      return AppRemoteConfig.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(AppRemoteConfig config) async {
    await _sharedPreferences.setString(
      _cachePayloadKey,
      jsonEncode(config.toJson()),
    );
    await _sharedPreferences.setInt(
      _cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<AppRemoteConfig> _fetchRemoteConfig() async {
    final response = await http
        .get(
          Uri.parse(_remoteConfigUrl),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 6));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Remote config request failed with ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Remote config payload must be a JSON object');
    }

    return AppRemoteConfig.fromJson(decoded);
  }
}
