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

import 'package:platform_detail/platform_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportIssueHelper {
  static Future<Uri> buildIssueUri({
    required String appVersion,
    required String appBuildNumber,
  }) async {
    final details = await PlatformDetail.environmentDetails();
    final body = StringBuffer()
      ..writeln('## Summary')
      ..writeln('Please describe the issue clearly and concisely.')
      ..writeln()
      ..writeln('## Steps to reproduce')
      ..writeln('1. ')
      ..writeln('2. ')
      ..writeln('3. ')
      ..writeln()
      ..writeln('## Expected behavior')
      ..writeln('What did you expect to happen?')
      ..writeln()
      ..writeln('## Actual behavior')
      ..writeln('What actually happened?')
      ..writeln()
      ..writeln('## Environment')
      ..writeln('- App version: $appVersion')
      ..writeln('- App build number: $appBuildNumber')
      ..writeln('- Platform: ${details.platform}')
      ..writeln('- Device model: ${details.deviceModel}')
      ..writeln('- Locale: ${details.locale}')
      ..writeln()
      ..writeln('## Additional context')
      ..writeln('Add screenshots, logs, or any other relevant context.');

    return Uri.https('github.com', '/vicajilau/quizdy/issues/new', {
      'title': 'Bug report',
      'body': body.toString(),
    });
  }

  static Future<bool> openIssueUrl(Uri url) async {
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
