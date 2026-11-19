import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/refuel.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';

/// Registro de um novo abastecimento.
class RefuelFormScreen extends StatefulWidget {
  const RefuelFormScreen({super.key});

  @override
  State<RefuelFormScreen> createState() => _RefuelFormScreenState();
}

class _RefuelFormScreenState extends State<RefuelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _kmController = TextEditingController();
  final _litersController = TextEditingController();

  FuelType _fuelType = FuelType.gasolina;
  DateTime _dateTime = DateTime.now();

  double get _total =>
      (parseNumber(_priceController.text) ?? 0) *
      (parseNumber(_litersController.text) ?? 0);

  @override
  void dispose() {
    _priceController.dispose();
    _kmController.dispose();
    _litersController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);

    final refuel = Refuel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fuelType: _fuelType,
      pricePerLiter: parseNumber(_priceController.text)!,
      odometer: parseNumber(_kmController.text)!,
      liters: parseNumber(_litersController.text)!,
      dateTime: _dateTime,
    );
    await state.addRefuel(refuel);
    navigator.pop();
  }

  String? _positive(String? v, String message) {
    final n = parseNumber(v);
    return (n == null || n <= 0) ? message : null;
  }

  @override
  Widget build(BuildContext context) {
    final decimalFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
    ];
    const decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Novo abastecimento')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Tipo de combustível'),
              const SizedBox(height: 8),
              SegmentedButton<FuelType>(
                segments: [
                  for (final f in FuelType.values)
                    ButtonSegment(value: f, label: Text(f.label)),
                ],
                selected: {_fuelType},
                onSelectionChanged: (s) => setState(() => _fuelType = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: decimalKeyboard,
                inputFormatters: decimalFormatters,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Preço por litro',
                  prefixText: r'R$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _positive(v, 'Informe o preço por litro'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litersController,
                keyboardType: decimalKeyboard,
                inputFormatters: decimalFormatters,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Litros abastecidos',
                  suffixText: 'L',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _positive(v, 'Informe a quantidade de litros'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Quilometragem atual',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final km = parseNumber(v);
                  if (km == null || km <= 0) return 'Informe a quilometragem';
                  return context.read<AppState>().validateOdometer(km, _dateTime);
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data e horário',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(formatDateTime(_dateTime)),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Valor total'),
                  trailing: Text(
                    formatMoney(_total),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Salvar abastecimento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
