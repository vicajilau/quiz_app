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

import 'package:quizdy/data/services/app_remote_config_service.dart';

enum AppVersionStatus { upToDate, updateAvailable, forceUpdateRequired }

class CheckAppVersionUseCase {
  /// Compares [installedVersion] against the remote config.
  ///
  /// Returns [AppVersionStatus.forceUpdateRequired] when the installed version
  /// is below [AppRemoteConfig.minimumSupportedVersion], and
  /// [AppVersionStatus.updateAvailable] when a newer [AppRemoteConfig.latestVersion]
  /// exists. Returns [AppVersionStatus.upToDate] otherwise.
  AppVersionStatus execute({
    required String installedVersion,
    required AppRemoteConfig remoteConfig,
  }) {
    final minimumRaw = remoteConfig.minimumSupportedVersion;
    if (minimumRaw != null) {
      final minimum = _parseVersion(minimumRaw);
      final installed = _parseVersion(installedVersion);
      if (minimum != null && installed != null && installed < minimum) {
        return AppVersionStatus.forceUpdateRequired;
      }
    }

    final latestRaw = remoteConfig.latestVersion;
    if (latestRaw != null) {
      final latest = _parseVersion(latestRaw);
      final installed = _parseVersion(installedVersion);
      if (latest != null && installed != null && installed < latest) {
        return AppVersionStatus.updateAvailable;
      }
    }

    return AppVersionStatus.upToDate;
  }

  /// Parses a semantic version string such as "1.2.3" into a comparable list.
  /// Returns `null` if the string is malformed.
  List<int>? _parseVersion(String raw) {
    try {
      final cleaned = raw.trim().split('+').first;
      final parts = cleaned.split('.').map(int.parse).toList();
      if (parts.length < 2 || parts.length > 3) return null;
      while (parts.length < 3) {
        parts.add(0);
      }
      return parts;
    } catch (_) {
      return null;
    }
  }
}

extension on List<int> {
  bool operator <(List<int> other) {
    for (var i = 0; i < length && i < other.length; i++) {
      if (this[i] < other[i]) return true;
      if (this[i] > other[i]) return false;
    }
    return false;
  }
}
