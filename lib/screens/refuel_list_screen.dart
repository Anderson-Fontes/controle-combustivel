import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/refuel.dart';
import '../state/app_state.dart';
import '../utils/calculations.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';

class RefuelListScreen extends StatelessWidget {
  const RefuelListScreen({super.key});

  Future<void> _remove(
      BuildContext context, AppState state, RefuelStat stat) async {
    final ok = await confirm(
      context,
      title: 'Excluir abastecimento?',
      message: 'O registro de ${formatDateTime(stat.refuel.dateTime)} será removido.',
      confirmLabel: 'Excluir',
    );
    if (ok) await state.removeRefuel(stat.refuel.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final stats = state.stats.reversed.toList(); // mais recente primeiro

    if (stats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum abastecimento registrado.\nToque em "Abastecer" para adicionar.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: stats.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final s = stats[i];
        final r = s.refuel;
        final indicators = s.kmPerLiter != null
            ? 'Distância: ${formatNumber(s.distance!, 0)} km · '
                '${formatNumber(s.kmPerLiter!)} km/L · '
                '${formatMoney(s.costPerKm!, digits: 3)}/km'
            : 'Abastecimento de referência (sem indicadores)';

        return Card(
          child: ListTile(
            isThreeLine: true,
            leading: const CircleAvatar(child: Icon(Icons.local_gas_station)),
            title: Text('${r.fuelType.label} · ${formatMoney(r.total)}'),
            subtitle: Text(
              '${formatDateTime(r.dateTime)}\n'
              '${formatNumber(r.liters)} L × ${formatMoney(r.pricePerLiter, digits: 3)}/L · '
              '${formatNumber(r.odometer, 0)} km\n'
              '$indicators',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _remove(context, state, s),
            ),
          ),
        );
      },
    );
  }
}