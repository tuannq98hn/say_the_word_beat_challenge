import 'package:dio/dio.dart';
import '../../data/error/failures.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(_handleError(error));
        },
      ),
    );
  }

  DioException _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] ?? 'Server error';

      switch (statusCode) {
        case 400:
          return DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: DioExceptionType.badResponse,
            error: ServerFailure('Bad Request: $message'),
          );
        case 401:
          return DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: DioExceptionType.badResponse,
            error: ServerFailure('Unauthorized: $message'),
          );
        case 404:
          return DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: DioExceptionType.badResponse,
            error: ServerFailure('Not Found: $message'),
          );
        case 500:
        default:
          return DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: DioExceptionType.badResponse,
            error: ServerFailure('Server Error: $message'),
          );
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return DioException(
        requestOptions: error.requestOptions,
        type: error.type,
        error: NetworkFailure('Connection timeout'),
      );
    } else {
      return DioException(
        requestOptions: error.requestOptions,
        type: error.type,
        error: NetworkFailure('Network error: ${error.message}'),
      );
    }
  }
}

