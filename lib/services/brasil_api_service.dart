import 'dart:convert';

import 'package:http/http.dart' as http;

class Brand {
  final String name;
  final String code;
  const Brand({required this.name, required this.code});
}

/// Consome a tabela FIPE exposta pela BrasilAPI.
///  - Marcas:  GET /api/fipe/marcas/v1/{tipoVeiculo}
///  - Modelos: GET /api/fipe/veiculos/v1/{tipoVeiculo}/{codigoMarca}
class BrasilApiService {
  static const _base = 'https://brasilapi.com.br/api/fipe';
  static const _vehicleType = 'carros';

  final http.Client _client;
  BrasilApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Brand>> fetchBrands() async {
    final data = await _getList('$_base/marcas/v1/$_vehicleType');
    final brands = data
        .whereType<Map<String, dynamic>>()
        .map((e) => Brand(name: '${e['nome']}', code: '${e['valor']}'))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return brands;
  }

  /// Modelos da marca escolhida (o código vem da lista de marcas).
  Future<List<String>> fetchModels(String brandCode) async {
    final data = await _getList('$_base/veiculos/v1/$_vehicleType/$brandCode');
    final models = data
        .whereType<Map<String, dynamic>>()
        .map((e) => '${e['modelo'] ?? e['nome'] ?? ''}'.trim())
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return models;
  }

  Future<List<dynamic>> _getList(String url) async {
    final response =
        await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) throw Exception('Resposta inesperada da API');
    return decoded;
  }
}
