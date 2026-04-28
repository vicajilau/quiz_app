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

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:platform_detail/platform_detail.dart';
import 'package:quizdy/core/debug_print.dart';
import 'package:quizdy/data/services/app_remote_config_service.dart';
import 'package:quizdy/domain/use_cases/check_app_version_use_case.dart';

part 'app_update_state.dart';

class AppUpdateCubit extends Cubit<AppUpdateState> {
  final AppRemoteConfigService _remoteConfigService;

  AppUpdateCubit({required AppRemoteConfigService remoteConfigService})
    : _remoteConfigService = remoteConfigService,
      super(const AppUpdateInitial()) {
    checkForUpdate();
  }

  /// Fetches the remote config, compares versions and emits the appropriate
  /// state. Must be called once the widget is mounted.
  ///
  /// On web, version checks are skipped and [AppUpdateUpToDate] is emitted.
  /// On Android, the Play Store In-App Update API is used directly and this
  /// cubit emits [AppUpdateUpToDate] regardless (the native UI handles the flow).
  Future<void> checkForUpdate() async {
    if (kIsWeb) {
      emit(const AppUpdateUpToDate());
      return;
    }

    try {
      final remoteConfig = await _remoteConfigService.getConfig();
      final versionDetails = await PlatformDetail.versionDetails();
      final installedVersion = versionDetails.version;

      final status = CheckAppVersionUseCase().execute(
        installedVersion: installedVersion,
        remoteConfig: remoteConfig,
      );

      switch (status) {
        case AppVersionStatus.upToDate:
          emit(const AppUpdateUpToDate());

        case AppVersionStatus.updateAvailable:
          await handleOptionalUpdate(remoteConfig.latestVersion!);

        case AppVersionStatus.forceUpdateRequired:
          await handleForceUpdate();
      }
    } catch (e) {
      printInDebug('[AppUpdateCubit] version check failed: $e');
      emit(const AppUpdateUpToDate());
    }
  }

  @protected
  Future<void> handleOptionalUpdate(String newVersion) async {
    if (PlatformDetail.isAndroid) {
      try {
        final info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable &&
            info.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
        }
      } catch (e) {
        // Expected in debug/sideloaded builds — Play In-App Updates only works
        // for apps installed from the Play Store (ERROR_APP_NOT_OWNED otherwise).
        printInDebug(
          '[AppUpdateCubit] Android flexible update unavailable: $e',
        );
      }
      emit(const AppUpdateUpToDate());
      return;
    }

    emit(AppUpdateAvailable(newVersion));
  }

  @protected
  Future<void> handleForceUpdate() async {
    if (PlatformDetail.isAndroid) {
      try {
        final info = await InAppUpdate.checkForUpdate();
        printInDebug(
          '[AppUpdateCubit] checkForUpdate result: '
          'availability=${info.updateAvailability}, '
          'immediateAllowed=${info.immediateUpdateAllowed}, '
          'flexibleAllowed=${info.flexibleUpdateAllowed}',
        );
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          // Skip immediateUpdateAllowed — it can be false in Internal Testing
          // even when the update is genuinely available. Let Play decide.
          final result = await InAppUpdate.performImmediateUpdate();
          if (result == AppUpdateResult.success) {
            emit(const AppUpdateUpToDate());
            return;
          }
          // User dismissed or update failed — fall through to ForceUpdateDialog
          // which blocks app usage via PopScope(canPop: false).
        }
      } catch (e) {
        // Expected in debug/sideloaded builds — Play In-App Updates only works
        // for apps installed from the Play Store (ERROR_APP_NOT_OWNED otherwise).
        printInDebug(
          '[AppUpdateCubit] Android immediate update unavailable: $e',
        );
      }
    }

    emit(const AppUpdateForceRequired());
  }
}
