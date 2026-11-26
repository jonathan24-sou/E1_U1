import 'package:flutter/material.dart';

import 'data/exchange_rate_service.dart';
import 'data/exchange_rates.dart';

void main() {
  runApp(const NotesExerciseApp());
}

class NotesExerciseApp extends StatelessWidget {
  const NotesExerciseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Notas y divisas',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: ExchangeRatePage(),
  );
}

class ExchangeRatePage extends StatefulWidget {
  final ExchangeRateService service;

  ExchangeRatePage({super.key, ExchangeRateService? service})
    : service = service ?? ExchangeRateService();

  @override
  State<ExchangeRatePage> createState() => _ExchangeRatePageState();
}

class _ExchangeRatePageState extends State<ExchangeRatePage> {
  late Future<ExchangeRates> _rates;

  @override
  void initState() {
    super.initState();
    _rates = widget.service.getLatestRates();
  }

  void _reload() {
    setState(() {
      _rates = widget.service.getLatestRates();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notas y tipo de cambio'),
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<ExchangeRates>(
      future: _rates,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is ExchangeRateException
              ? error.message
              : 'No se pudieron cargar las divisas: $error';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final rates = snapshot.requireData;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Base: ${rates.base}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Fecha: ${rates.date.toIso8601String().split('T').first}'),
              const SizedBox(height: 16),
              for (final currency in ['USD', 'EUR'])
                Text(
                  '1 ${rates.base} = ${rates.rates[currency]?.toStringAsFixed(4) ?? 'Sin dato'} $currency',
                ),
            ],
          ),
        );
      },
    ),
  );
}
