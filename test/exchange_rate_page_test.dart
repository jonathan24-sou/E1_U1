import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:e1_u1/data/exchange_rate_service.dart';
import 'package:e1_u1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra las tasas recibidas del servicio', (tester) async {
    final dio = Dio()
      ..httpClientAdapter = _TestAdapter(
        ResponseBody.fromString(
          '{"base":"MXN","date":"2026-11-25","rates":{"USD":0.05,"EUR":0.046}}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        ),
      );

    await tester.pumpWidget(
      MaterialApp(
        home: ExchangeRatePage(service: ExchangeRateService(dio: dio)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Base: MXN'), findsOneWidget);
    expect(find.text('Fecha: 2026-11-25'), findsOneWidget);
    expect(find.text('1 MXN = 0.0500 USD'), findsOneWidget);
    expect(find.text('1 MXN = 0.0460 EUR'), findsOneWidget);
  });
}

class _TestAdapter implements HttpClientAdapter {
  final ResponseBody _response;

  _TestAdapter(this._response);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => _response;

  @override
  void close({bool force = false}) {}
}
