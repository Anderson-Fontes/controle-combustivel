import 'package:flutter/foundation.dart';

import '../models/refuel.dart';
import '../models/vehicle.dart';
import '../services/storage_service.dart';
import '../utils/calculations.dart';
import '../utils/formatters.dart';

/// Estado global do app (Provider + ChangeNotifier).
class AppState extends ChangeNotifier {
  final StorageService _storage;
  AppState({StorageService? storage}) : _storage = storage ?? StorageService();

  Vehicle? _vehicle;
  List<Refuel> _refuels = [];
  bool _loading = true;

  Vehicle? get vehicle => _vehicle;
  bool get loading => _loading;
  List<Refuel> get refuels => List.unmodifiable(_refuels);
  List<RefuelStat> get stats => buildStats(_refuels);

  Future<void> load() async {
    _vehicle = await _storage.loadVehicle();
    _refuels = _vehicle == null ? [] : await _storage.loadRefuels();
    _sort();
    _loading = false;
    notifyListeners();
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    _vehicle = vehicle;
    await _storage.saveVehicle(vehicle);
    notifyListeners();
  }

  /// Exclui o veículo E os abastecimentos associados.
  Future<void> deleteVehicle() async {
    _vehicle = null;
    _refuels = [];
    await _storage.clearAll();
    notifyListeners();
  }

  Future<void> addRefuel(Refuel refuel) async {
    _refuels.add(refuel);
    _sort();
    await _storage.saveRefuels(_refuels);
    notifyListeners();
  }

  Future<void> removeRefuel(String id) async {
    _refuels.removeWhere((r) => r.id == id);
    await _storage.saveRefuels(_refuels);
    notifyListeners();
  }

  /// A quilometragem precisa ser coerente com a ordem cronológica:
  /// maior que a do abastecimento anterior e menor que a do seguinte.
  String? validateOdometer(double km, DateTime date) {
    Refuel? previous;
    Refuel? next;
    for (final r in _refuels) {
      if (r.dateTime.isBefore(date)) {
        previous = r;
      } else {
        next ??= r;
      }
    }
    if (previous != null && km <= previous.odometer) {
      return 'Deve ser maior que ${formatNumber(previous.odometer, 0)} km '
          '(abastecimento anterior)';
    }
    if (next != null && km >= next.odometer) {
      return 'Deve ser menor que ${formatNumber(next.odometer, 0)} km '
          '(abastecimento seguinte)';
    }
    return null;
  }

  void _sort() => _refuels.sort((a, b) => a.dateTime.compareTo(b.dateTime));
}
