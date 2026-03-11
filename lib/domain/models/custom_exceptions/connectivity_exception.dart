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

enum ConnectivityExceptionType { noInternet, connectionAborted }

/// Thrown when a network request fails due to connectivity issues.
///
/// Use [type] to pick the appropriate localized message:
/// - [ConnectivityExceptionType.noInternet] → `noInternetConnection`
/// - [ConnectivityExceptionType.connectionAborted] → `aiErrorConnectionAborted`
class ConnectivityException implements Exception {
  const ConnectivityException([
    this.type = ConnectivityExceptionType.noInternet,
  ]);

  final ConnectivityExceptionType type;

  @override
  String toString() => 'ConnectivityException(${type.name})';
}
