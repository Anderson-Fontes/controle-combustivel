class Vehicle {
  final String brand;
  final String model;
  final int year;
  final double engineLiters; // cilindrada em litros (ex.: 1.0, 1.6)

  const Vehicle({
    required this.brand,
    required this.model,
    required this.year,
    required this.engineLiters,
  });

  String get title => '$brand $model';

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        'year': year,
        'engineLiters': engineLiters,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        brand: json['brand'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        engineLiters: (json['engineLiters'] as num).toDouble(),
      );
}
