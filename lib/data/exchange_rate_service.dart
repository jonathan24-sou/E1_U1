import 'package:dio/dio.dart';

import 'exchange_rates.dart';

enum ExchangeRateErrorKind { timeout, notFound, server, http, network }

class ExchangeRateException implements Exception {
  final ExchangeRateErrorKind kind;
  final int? statusCode;

  const ExchangeRateException(this.kind, {this.statusCode});

  String get message => switch (kind) {
    ExchangeRateErrorKind.timeout => 'La consulta agotó el tiempo de espera.',
    ExchangeRateErrorKind.notFound =>
      'No se encontró el recurso solicitado (404).',
    ExchangeRateErrorKind.server => 'El servidor de divisas falló (5xx).',
    ExchangeRateErrorKind.http => 'La API respondió con HTTP $statusCode.',
    ExchangeRateErrorKind.network =>
      'No se pudo conectar con la API de divisas.',
  };

  @override
  String toString() => message;
}

class ExchangeRateService {
  static const _url = 'https://api.exchangerate-api.com/v4/latest/MXN';

  final Dio _dio;

  ExchangeRateService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
          );

  Future<ExchangeRates> getLatestRates() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(_url);
      final data = response.data;
      if (data == null) {
        throw const FormatException('La respuesta de la API está vacía.');
      }
      return ExchangeRates.fromJson(data);
    } on FormatException {
      rethrow;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  ExchangeRateException _mapError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 404) {
      return const ExchangeRateException(ExchangeRateErrorKind.notFound);
    }
    if (statusCode != null && statusCode >= 500) {
      return ExchangeRateException(
        ExchangeRateErrorKind.server,
        statusCode: statusCode,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ExchangeRateException(ExchangeRateErrorKind.timeout);
    }
    if (statusCode != null) {
      return ExchangeRateException(
        ExchangeRateErrorKind.http,
        statusCode: statusCode,
      );
    }
    return const ExchangeRateException(ExchangeRateErrorKind.network);
  }
}
