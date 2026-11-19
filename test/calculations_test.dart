import 'package:controle_combustivel/models/refuel.dart';
import 'package:controle_combustivel/utils/calculations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('primeiro abastecimento é referência; os seguintes têm indicadores', () {
    final refuels = [
      Refuel(
        id: '1',
        fuelType: FuelType.gasolina,
        pricePerLiter: 5.80,
        odometer: 10000,
        liters: 40,
        dateTime: DateTime(2026, 10, 1),
      ),
      Refuel(
        id: '2',
        fuelType: FuelType.gasolina,
        pricePerLiter: 5.90,
        odometer: 10450,
        liters: 38,
        dateTime: DateTime(2026, 10, 15),
      ),
    ];

    final stats = buildStats(refuels);

    expect(stats[0].kmPerLiter, isNull);
    expect(stats[0].costPerKm, isNull);
    expect(stats[1].distance, 450);
    expect(stats[1].kmPerLiter, closeTo(450 / 38, 0.0001)); // ≈ 11,84 km/L
    expect(stats[1].costPerKm, closeTo(38 * 5.90 / 450, 0.0001)); // ≈ R$ 0,498/km
  });

  test('valor total = preço por litro x litros', () {
    final r = Refuel(
      id: '1',
      fuelType: FuelType.etanol,
      pricePerLiter: 4.0,
      odometer: 100,
      liters: 10,
      dateTime: DateTime(2026, 1, 1),
    );
    expect(r.total, 40.0);
  });
}
