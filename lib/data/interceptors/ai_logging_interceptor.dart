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

class AiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final cleanUri = options.uri.toString().replaceAll(
        RegExp(r'key=[^&]+'),
        'key=REDACTED',
      );

      debugPrint('\n🚀 --- AI REQUEST ---');
      debugPrint('📍 URI:   $cleanUri');
      debugPrint('🛠️ METHOD: ${options.method}');

      if (options.data != null) {
        debugPrint('📦 DATA:');
        _printPrettyJson(options.data);
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━\n');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('\n✨ --- AI RESPONSE ---');
      debugPrint('✅ STATUS: ${response.statusCode}');

      if (response.data != null) {
        debugPrint('📊 DATA:');
        _printPrettyJson(response.data);
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('\n❌ --- AI ERROR ---');
      debugPrint('🚫 STATUS:  ${err.response?.statusCode}');
      debugPrint('⚠️ MESSAGE: ${err.message}');

      if (err.response?.data != null) {
        debugPrint('📄 ERROR DATA:');
        _printPrettyJson(err.response?.data);
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━\n');
    }
    return super.onError(err, handler);
  }

  void _printPrettyJson(dynamic data) {
    try {
      if (data is FormData) {
        debugPrint(
          '   [FormData with ${data.files.length} files and ${data.fields.length} fields]',
        );
        return;
      }

      if (data is List && data.isNotEmpty && data.first is num) {
        debugPrint('   [Byte Array Output of length ${data.length}]');
        return;
      }

      dynamic jsonObject = data;
      if (data is String) {
        try {
          jsonObject = jsonDecode(data);
        } catch (_) {
          // Keep as string if not valid JSON
        }
      } else {
        try {
          // Deep copy to avoid mutating actual request data
          jsonObject = jsonDecode(jsonEncode(data));
        } catch (_) {}
      }

      // Hide huge inline_data payload from logs
      if (jsonObject is Map<String, dynamic>) {
        try {
          final contents = jsonObject['contents'];
          if (contents is List) {
            for (var content in contents) {
              if (content is Map) {
                final parts = content['parts'];
                if (parts is List) {
                  for (var part in parts) {
                    if (part is Map && part.containsKey('inline_data')) {
                      final inlineData = part['inline_data'];
                      if (inlineData is Map && inlineData.containsKey('data')) {
                        final String originalData = inlineData['data']
                            .toString();
                        if (originalData.length > 50) {
                          inlineData['data'] =
                              '${originalData.substring(0, 50)}... [TRUNCATED BASE64]';
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (_) {}
      }

      const encoder = JsonEncoder.withIndent('  ');
      final prettyString = encoder.convert(jsonObject);

      // Split by line to avoid debugPrint truncation issues and for better readability
      final lines = prettyString.split('\n');
      const maxLines = 100;

      for (int i = 0; i < lines.length && i < maxLines; i++) {
        debugPrint('   ${lines[i]}');
      }

      if (lines.length > maxLines) {
        debugPrint('   ... (TRUNCATED ${lines.length - maxLines} LINES) ...');
      }
    } catch (e) {
      debugPrint('   ${data.toString()}');
    }
  }
}
