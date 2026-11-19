import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/refuel.dart';
import '../models/vehicle.dart';

/// Persistência local (JSON em SharedPreferences). Funciona em Android,
/// iOS, Web e Desktop e sobrevive ao fechamento do app.
class StorageService {
  static const _vehicleKey = 'vehicle';
  static const _refuelsKey = 'refuels';

  Future<Vehicle?> loadVehicle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_vehicleKey);
      if (raw == null) return null;
      return Vehicle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vehicleKey, jsonEncode(vehicle.toJson()));
  }

  Future<List<Refuel>> loadRefuels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_refuelsKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Refuel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRefuels(List<Refuel> refuels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _refuelsKey,
      jsonEncode(refuels.map((r) => r.toJson()).toList()),
    );
  }

  /// Remove o veículo e todos os abastecimentos associados.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vehicleKey);
    await prefs.remove(_refuelsKey);
  }
}
