import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/charts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<AppState>().stats;

    if (stats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum abastecimento registrado ainda.\nToque em "Abastecer" para começar.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final withIndicators = stats.where((s) => s.kmPerLiter != null).toList();
    final totalSpent = stats.fold<double>(0, (sum, s) => sum + s.refuel.total);
    final avgKmL = withIndicators.isEmpty
        ? null
        : withIndicators.map((s) => s.kmPerLiter!).reduce((a, b) => a + b) /
            withIndicators.length;
    final avgCostKm = withIndicators.isEmpty
        ? null
        : withIndicators.map((s) => s.costPerKm!).reduce((a, b) => a + b) /
            withIndicators.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _SummaryCard('Total gasto', formatMoney(totalSpent))),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                'Média km/L',
                avgKmL == null ? '—' : formatNumber(avgKmL),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                'Média R\$/km',
                avgCostKm == null ? '—' : formatMoney(avgCostKm, digits: 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Valor de cada abastecimento (R\$)',
          child: SeriesBarChart(
            values: stats.map((s) => s.refuel.total).toList(),
            labels: stats.map((s) => formatShortDate(s.refuel.dateTime)).toList(),
            tooltipFormat: formatMoney,
          ),
        ),
        _ChartCard(
          title: 'Consumo (km/L)',
          child: withIndicators.isEmpty
              ? const _NeedMoreData()
              : SeriesLineChart(
                  values: withIndicators.map((s) => s.kmPerLiter!).toList(),
                  labels: withIndicators
                      .map((s) => formatShortDate(s.refuel.dateTime))
                      .toList(),
                  tooltipFormat: (v) => '${formatNumber(v)} km/L',
                ),
        ),
        _ChartCard(
          title: 'Custo por quilômetro (R\$/km)',
          child: withIndicators.isEmpty
              ? const _NeedMoreData()
              : SeriesLineChart(
                  values: withIndicators.map((s) => s.costPerKm!).toList(),
                  labels: withIndicators
                      .map((s) => formatShortDate(s.refuel.dateTime))
                      .toList(),
                  axisDigits: 2,
                  tooltipFormat: (v) => '${formatMoney(v, digits: 3)}/km',
                ),
        ),
        const SizedBox(height: 72), // espaço para o botão flutuante
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            FittedBox(
              child: Text(value, style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _NeedMoreData extends StatelessWidget {
  const _NeedMoreData();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: Text(
          'Registre pelo menos 2 abastecimentos\npara ver este indicador.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
