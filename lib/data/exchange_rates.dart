class ExchangeRates {
  final String base;
  final DateTime date;
  final Map<String, double> rates;

  ExchangeRates({
    required this.base,
    required this.date,
    required Map<String, double> rates,
  }) : rates = Map.unmodifiable(rates);

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'];
    if (json['base'] is! String ||
        json['date'] is! String ||
        rawRates is! Map) {
      throw const FormatException('Respuesta de divisas con formato inválido.');
    }

    final parsedRates = <String, double>{};
    for (final entry in rawRates.entries) {
      if (entry.key is! String || entry.value is! num) {
        throw const FormatException(
          'La respuesta contiene un tipo de cambio inválido.',
        );
      }
      parsedRates[entry.key as String] = (entry.value as num).toDouble();
    }

    return ExchangeRates(
      base: json['base'] as String,
      date: DateTime.parse(json['date'] as String),
      rates: parsedRates,
    );
  }
}
