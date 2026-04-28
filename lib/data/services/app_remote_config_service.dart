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

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizdy/core/debug_print.dart';

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
      homeFeedbackEnabled: false,
      homeFeedbackUrl: defaultFeedbackUrl,
      latestVersion: null,
      minimumSupportedVersion: null,
    );
  }

  factory AppRemoteConfig.fromJson(Map<String, dynamic> json) {
    final bool? feedbackEnabled = json['homeFeedbackEnabled'];
    final String? feedbackUrl = json['homeFeedbackUrl'];

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

  static String? _asCleanString(Object? value) {
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
  static const String _localConfigAssetPath = 'app_config.json';
  static const Duration _cacheTtl = Duration(hours: 1);

  final SharedPreferences _sharedPreferences;
  final Dio _dio;

  AppRemoteConfigService({
    required SharedPreferences sharedPreferences,
    required Dio dio,
  }) : _sharedPreferences = sharedPreferences,
       _dio = dio;

  Future<AppRemoteConfig> getConfig({bool forceRefresh = false}) async {
    final cachedConfig = _readCachedConfig();
    final isCacheValid = _isCacheValid();

    printInDebug(
      '[AppRemoteConfigService] getConfig(forceRefresh: $forceRefresh, '
      'cacheValid: $isCacheValid)',
    );
    if (cachedConfig != null) {
      _logConfig('cache_read', cachedConfig);
    } else {
      printInDebug('[AppRemoteConfigService] cache_read -> <empty>');
    }

    if (!forceRefresh && isCacheValid) {
      if (cachedConfig != null) {
        printInDebug('[AppRemoteConfigService] source=cache');
        return cachedConfig;
      }

      final localConfig = await _loadLocalConfigAsset();
      if (localConfig != null) {
        printInDebug(
          '[AppRemoteConfigService] cache valid but payload missing, source=local_asset',
        );
        return localConfig;
      }

      final defaults = AppRemoteConfig.defaults();
      printInDebug(
        '[AppRemoteConfigService] cache valid but payload missing, source=defaults',
      );
      _logConfig('defaults_returned', defaults);
      return defaults;
    }

    try {
      final remoteConfig = await _fetchRemoteConfig();
      _logConfig('remote_fetched', remoteConfig);
      await _writeCache(remoteConfig);
      printInDebug('[AppRemoteConfigService] source=remote');
      return remoteConfig;
    } catch (error) {
      printInDebug(
        '[AppRemoteConfigService] remote fetch failed, fallback path engaged: $error',
      );
      if (cachedConfig != null && !kDebugMode) {
        printInDebug('[AppRemoteConfigService] source=fallback_cache');
        return cachedConfig;
      }

      final localConfig = await _loadLocalConfigAsset();
      if (localConfig != null) {
        printInDebug('[AppRemoteConfigService] source=fallback_local_asset');
        return localConfig;
      }

      final defaults = AppRemoteConfig.defaults();
      printInDebug('[AppRemoteConfigService] source=fallback_defaults');
      _logConfig('defaults_returned', defaults);
      return defaults;
    }
  }

  Future<AppRemoteConfig> refreshConfig() {
    return getConfig(forceRefresh: true);
  }

  bool _isCacheValid() {
    if (kDebugMode) return false;

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
    _logConfig('cache_write', config);
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
    final response = await _dio.get<Object>(
      _remoteConfigUrl,
      queryParameters: {'t': DateTime.now().millisecondsSinceEpoch},
      options: Options(
        headers: {'Accept': 'application/json'},
        receiveTimeout: const Duration(seconds: 6),
      ),
    );

    final responseData = response.data;
    final Map<String, dynamic> configMap;

    if (responseData is String) {
      final decoded = jsonDecode(responseData);
      if (decoded is Map<String, dynamic>) {
        configMap = decoded;
      } else {
        throw Exception('Remote config payload string is not a JSON object');
      }
    } else if (responseData is Map<String, dynamic>) {
      configMap = responseData;
    } else {
      throw Exception(
        'Remote config payload must be a JSON object or a string',
      );
    }

    printInDebug('[AppRemoteConfigService] raw_body: $configMap');
    return AppRemoteConfig.fromJson(configMap);
  }

  Future<AppRemoteConfig?> _loadLocalConfigAsset() async {
    try {
      final payload = await rootBundle.loadString(_localConfigAssetPath);
      if (payload.trim().isEmpty) return null;

      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;

      final config = AppRemoteConfig.fromJson(decoded);
      _logConfig('local_asset_read', config);
      return config;
    } catch (error) {
      printInDebug('[AppRemoteConfigService] local asset load failed: $error');
      return null;
    }
  }

  void _logConfig(String source, AppRemoteConfig config) {
    printInDebug(
      '[AppRemoteConfigService][$source] '
      'homeFeedbackEnabled=${config.homeFeedbackEnabled}, '
      'homeFeedbackUrl=${config.homeFeedbackUrl}, '
      'latestVersion=${config.latestVersion}, '
      'minimumSupportedVersion=${config.minimumSupportedVersion}',
    );
  }
}
