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

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:quizdy/core/debug_print.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';

class DeepLinkHandler {
  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;

  /// Initializes deep link listening. Should be called during app startup.
  static Future<void> initialize() async {
    if (kIsWeb) return; // Web handles links via GoRouter and HomeScreen

    // Check initial link if app was launched from a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      printInDebug('Failed to get initial deep link: $e');
    }

    // Attach a listener to the stream for when the app is in the background
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        printInDebug('Deep link stream error: $err');
      },
    );
  }

  /// Processes the incoming deep link URI.
  static void _handleDeepLink(Uri uri) {
    printInDebug('Received deep link: $uri');

    // Example deep link: quizdy://open?data=https://...
    if (uri.queryParameters.containsKey('data')) {
      final dataUrl = uri.queryParameters['data'];
      if (dataUrl != null && dataUrl.isNotEmpty) {
        try {
          final fileBloc = ServiceLocator.getIt<FileBloc>();
          // Dispatch FileDropped to trigger downloading and opening the remote quiz file
          fileBloc.add(FileDropped(dataUrl));
        } catch (e) {
          printInDebug('Error dispatching FileDropped from deep link: $e');
        }
      }
    }
  }

  /// Cleans up the listener.
  static void dispose() {
    _linkSubscription?.cancel();
  }
}
