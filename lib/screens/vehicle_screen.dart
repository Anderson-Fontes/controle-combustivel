import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  Future<void> _delete(BuildContext context, AppState state) async {
    final ok = await confirm(
      context,
      title: 'Excluir veículo?',
      message: 'Isso também removerá os ${state.refuels.length} abastecimento(s) '
          'associado(s). Essa ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
    );
    // Sem veículo, a tela raiz volta para o cadastro automaticamente.
    if (ok) await state.deleteVehicle();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final v = state.vehicle;
    if (v == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        v.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _InfoRow('Marca', v.brand),
                _InfoRow('Modelo', v.model),
                _InfoRow('Ano', '${v.year}'),
                _InfoRow('Cilindrada', '${formatNumber(v.engineLiters, 1)} L'),
                _InfoRow('Abastecimentos', '${state.refuels.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _delete(context, state),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Excluir veículo'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Só é possível ter um veículo por vez. Para cadastrar outro, exclua o '
          'atual — os abastecimentos dele também serão removidos.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
      ),
    );
  }
}
