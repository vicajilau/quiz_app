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

part of 'app_update_cubit.dart';

sealed class AppUpdateState {
  const AppUpdateState();
}

/// Initial state — check not yet performed.
final class AppUpdateInitial extends AppUpdateState {
  const AppUpdateInitial();
}

/// The installed version is up to date.
final class AppUpdateUpToDate extends AppUpdateState {
  const AppUpdateUpToDate();
}

/// A newer optional version is available. Show a dismissible banner.
final class AppUpdateAvailable extends AppUpdateState {
  final String newVersion;

  const AppUpdateAvailable(this.newVersion);
}

/// The installed version is below the minimum supported version.
/// The user must update to continue using the app.
final class AppUpdateForceRequired extends AppUpdateState {
  const AppUpdateForceRequired();
}
