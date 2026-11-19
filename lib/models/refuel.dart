enum FuelType { etanol, gasolina, diesel }

extension FuelTypeLabel on FuelType {
  String get label {
    switch (this) {
      case FuelType.etanol:
        return 'Etanol';
      case FuelType.gasolina:
        return 'Gasolina';
      case FuelType.diesel:
        return 'Diesel';
    }
  }
}

class Refuel {
  final String id;
  final FuelType fuelType;
  final double pricePerLiter; // R$/L
  final double odometer; // km no momento do abastecimento
  final double liters;
  final DateTime dateTime;

  const Refuel({
    required this.id,
    required this.fuelType,
    required this.pricePerLiter,
    required this.odometer,
    required this.liters,
    required this.dateTime,
  });

  /// Valor total = preço por litro x litros.
  double get total => pricePerLiter * liters;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fuelType': fuelType.name,
        'pricePerLiter': pricePerLiter,
        'odometer': odometer,
        'liters': liters,
        'dateTime': dateTime.toIso8601String(),
      };

  factory Refuel.fromJson(Map<String, dynamic> json) => Refuel(
        id: json['id'] as String,
        fuelType: FuelType.values.byName(json['fuelType'] as String),
        pricePerLiter: (json['pricePerLiter'] as num).toDouble(),
        odometer: (json['odometer'] as num).toDouble(),
        liters: (json['liters'] as num).toDouble(),
        dateTime: DateTime.parse(json['dateTime'] as String),
      );
}
