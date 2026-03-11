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

import 'package:dio/dio.dart';
import 'package:quizdy/data/utils/connectivity_error_helper.dart';
import 'package:quizdy/domain/models/custom_exceptions/connectivity_exception.dart';

/// Global Dio interceptor that converts connectivity-related [DioException]s
/// into [ConnectivityException] so callers can handle network availability
/// uniformly without depending on Dio types.
class ConnectivityInterceptor extends Interceptor {
  static const _connectivityTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final errorStr = err.error?.toString() ?? '';
    final isAborted = isAbortedError(errorStr);

    final isConnectivityError = _connectivityTypes.contains(err.type) ||
        (err.type == DioExceptionType.unknown && isSocketException(err.error)) ||
        isAborted;

    if (!isConnectivityError) {
      super.onError(err, handler);
      return;
    }

    final type = isAborted
        ? ConnectivityExceptionType.connectionAborted
        : ConnectivityExceptionType.noInternet;

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ConnectivityException(type),
        type: err.type,
      ),
    );
  }
}
