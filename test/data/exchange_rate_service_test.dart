import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:e1_u1/data/exchange_rate_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parsea una respuesta válida de divisas', () async {
    final service = _serviceWithResponse(
      ResponseBody.fromString(
        '{"base":"MXN","date":"2026-11-25","rates":{"USD":0.05}}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );

    final rates = await service.getLatestRates();

    expect(rates.base, 'MXN');
    expect(rates.date, DateTime(2026, 11, 25));
    expect(rates.rates['USD'], 0.05);
  });

  test('clasifica las respuestas 404 y 500', () async {
    for (final entry in {
      404: ExchangeRateErrorKind.notFound,
      500: ExchangeRateErrorKind.server,
    }.entries) {
      final service = _serviceWithResponse(
        ResponseBody.fromString('{}', entry.key),
      );

      await expectLater(
        service.getLatestRates(),
        throwsA(
          isA<ExchangeRateException>().having(
            (error) => error.kind,
            'kind',
            entry.value,
          ),
        ),
      );
    }
  });

  test('clasifica el timeout de conexión', () async {
    final dio = Dio()
      ..httpClientAdapter = _TestAdapter((request) {
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionTimeout,
        );
      });

    await expectLater(
      ExchangeRateService(dio: dio).getLatestRates(),
      throwsA(
        isA<ExchangeRateException>().having(
          (error) => error.kind,
          'kind',
          ExchangeRateErrorKind.timeout,
        ),
      ),
    );
  });
}

ExchangeRateService _serviceWithResponse(ResponseBody body) {
  final dio = Dio()..httpClientAdapter = _TestAdapter((_) => body);
  return ExchangeRateService(dio: dio);
}

class _TestAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions request) _response;

  _TestAdapter(this._response);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => _response(options);

  @override
  void close({bool force = false}) {}
}
