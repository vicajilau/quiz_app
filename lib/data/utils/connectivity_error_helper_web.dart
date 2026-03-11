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

/// Returns false always on Web since SocketException doesn't exist.
bool isSocketException(dynamic error) => false;

/// Returns true if the [errorStr] matches any common or Web-specific aborted message.
bool isAbortedError(String errorStr) {
  const abortedMessages = [
    'Software caused connection abort',
    'Connection closed',
    'XMLHttpRequest error',
    'Failed to fetch',
  ];
  return abortedMessages.any(errorStr.contains);
}
