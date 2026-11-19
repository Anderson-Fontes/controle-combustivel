import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../services/brasil_api_service.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/picker_field.dart';

/// Cadastro do veículo (marca/modelo vêm da BrasilAPI).
class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = BrasilApiService();
  final _yearController = TextEditingController();
  final _engineController = TextEditingController();

  List<Brand> _brands = [];
  Brand? _selectedBrand;
  List<String> _models = [];
  String? _selectedModel;
  bool _loadingBrands = false;
  bool _loadingModels = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _engineController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _loadingBrands = true;
      _error = null;
    });
    try {
      final brands = await _api.fetchBrands();
      if (!mounted) return;
      setState(() => _brands = brands);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error =
          'Não foi possível carregar as marcas. Verifique sua conexão.');
    } finally {
      if (mounted) setState(() => _loadingBrands = false);
    }
  }

  Future<void> _selectBrand(String name) async {
    final brand = _brands.firstWhere((b) => b.name == name);
    setState(() {
      _selectedBrand = brand;
      _selectedModel = null; // o modelo depende da marca
      _models = [];
    });
    await _loadModels(brand);
  }

  Future<void> _loadModels(Brand brand) async {
    setState(() {
      _loadingModels = true;
      _error = null;
    });
    try {
      final models = await _api.fetchModels(brand.code);
      if (!mounted || _selectedBrand != brand) return;
      setState(() => _models = models);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error =
          'Não foi possível carregar os modelos. Verifique sua conexão.');
    } finally {
      if (mounted) setState(() => _loadingModels = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final vehicle = Vehicle(
      brand: _selectedBrand!.name,
      model: _selectedModel!,
      year: int.parse(_yearController.text),
      engineLiters: parseNumber(_engineController.text)!,
    );
    // A tela raiz troca automaticamente para o Dashboard quando houver veículo.
    await state.saveVehicle(vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar veículo')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Cadastre seu veículo para começar a registrar abastecimentos.',
              ),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(
                    leading: const Icon(Icons.wifi_off),
                    title: Text(_error!),
                    trailing: TextButton(
                      onPressed: () => _selectedBrand == null
                          ? _loadBrands()
                          : _loadModels(_selectedBrand!),
                      child: const Text('Tentar de novo'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              PickerField(
                label: 'Marca',
                items: _brands.map((b) => b.name).toList(),
                value: _selectedBrand?.name,
                loading: _loadingBrands,
                onSelected: _selectBrand,
                validator: (v) => v == null ? 'Selecione a marca' : null,
              ),
              const SizedBox(height: 16),
              PickerField(
                label: 'Modelo',
                items: _models,
                value: _selectedModel,
                enabled: _selectedBrand != null,
                loading: _loadingModels,
                onSelected: (m) => setState(() => _selectedModel = m),
                validator: (v) => v == null ? 'Selecione o modelo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final year = int.tryParse(v ?? '');
                  if (year == null) return 'Informe o ano';
                  if (year < 1900 || year > DateTime.now().year + 1) {
                    return 'Ano inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _engineController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Cilindrada do motor',
                  hintText: 'Ex.: 1.0 ou 1,6',
                  suffixText: 'L',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = parseNumber(v);
                  if (n == null || n <= 0 || n > 10) {
                    return 'Informe a cilindrada em litros (ex.: 1.6)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Salvar veículo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
