import '../models/refuel.dart';

/// Um abastecimento + indicadores calculados em relação ao anterior.
/// No primeiro abastecimento (referência inicial) os indicadores são nulos.
class RefuelStat {
  final Refuel refuel;
  final double? distance; // km percorridos desde o abastecimento anterior
  final double? kmPerLiter; // distância / litros do abastecimento atual
  final double? costPerKm; // valor total do abastecimento atual / distância

  const RefuelStat({
    required this.refuel,
    this.distance,
    this.kmPerLiter,
    this.costPerKm,
  });
}

/// Calcula os indicadores seguindo exatamente as fórmulas da atividade
/// (todos os registros são considerados "tanque cheio").
List<RefuelStat> buildStats(List<Refuel> refuels) {
  final sorted = [...refuels]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  final result = <RefuelStat>[];

  for (var i = 0; i < sorted.length; i++) {
    final current = sorted[i];
    if (i == 0) {
      result.add(RefuelStat(refuel: current));
      continue;
    }
    final distance = current.odometer - sorted[i - 1].odometer;
    if (distance <= 0 || current.liters <= 0) {
      result.add(RefuelStat(refuel: current, distance: distance));
      continue;
    }
    result.add(RefuelStat(
      refuel: current,
      distance: distance,
      kmPerLiter: distance / current.liters,
      costPerKm: current.total / distance,
    ));
  }
  return result;
}
