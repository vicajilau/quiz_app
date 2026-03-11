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
