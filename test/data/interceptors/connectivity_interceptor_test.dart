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

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizdy/data/interceptors/connectivity_interceptor.dart';
import 'package:quizdy/domain/models/custom_exceptions/connectivity_exception.dart';

class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

class DioExceptionFake extends Fake implements DioException {}
class RequestOptionsFake extends Fake implements RequestOptions {}

void main() {
  late ConnectivityInterceptor interceptor;
  late MockErrorInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(DioExceptionFake());
    registerFallbackValue(RequestOptionsFake());
  });

  setUp(() {
    interceptor = ConnectivityInterceptor();
    mockHandler = MockErrorInterceptorHandler();
  });

  group('ConnectivityInterceptor', () {
    test('should reject with noInternet when DioExceptionType.connectionError', () {
      final err = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      );

      when(() => mockHandler.reject(any())).thenAnswer((_) {});

      interceptor.onError(err, mockHandler);

      verify(() => mockHandler.reject(any(that: predicate((DioException e) {
        final error = e.error as ConnectivityException;
        return error.type == ConnectivityExceptionType.noInternet;
      })))).called(1);
    });

    test('should reject with noInternet when SocketException occurs (native scenario)', () {
      final err = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
        error: const SocketException('No connection'),
      );

      when(() => mockHandler.reject(any())).thenAnswer((_) {});

      interceptor.onError(err, mockHandler);

      verify(() => mockHandler.reject(any(that: predicate((DioException e) {
        final error = e.error as ConnectivityException;
        return error.type == ConnectivityExceptionType.noInternet;
      })))).called(1);
    });

    test('should reject with connectionAborted when error string contains aborted message', () {
      final err = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
        error: 'Connection closed',
      );

      when(() => mockHandler.reject(any())).thenAnswer((_) {});

      interceptor.onError(err, mockHandler);

      verify(() => mockHandler.reject(any(that: predicate((DioException e) {
        final error = e.error as ConnectivityException;
        return error.type == ConnectivityExceptionType.connectionAborted;
      })))).called(1);
    });

    test('should pass through non-connectivity errors', () {
      final err = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
      );

      when(() => mockHandler.next(err)).thenAnswer((_) {});

      interceptor.onError(err, mockHandler);

      verify(() => mockHandler.next(err)).called(1);
      verifyNever(() => mockHandler.reject(any()));
    });
  });
}
