import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart';

FlTitlesData _titles({
  required List<String> labels,
  required int axisDigits,
  required double leftInterval,
}) {
  final step = math.max(1, (labels.length / 5).ceil());
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final i = value.round();
          if (i < 0 || i >= labels.length || i % step != 0) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(labels[i], style: const TextStyle(fontSize: 10)),
          );
        },
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 44,
        interval: math.max(leftInterval, 0.01),
        getTitlesWidget: (value, meta) => Text(
          formatNumber(value, axisDigits),
          style: const TextStyle(fontSize: 10),
        ),
      ),
    ),
  );
}

double _min(List<double> v) => v.reduce((a, b) => a < b ? a : b);
double _max(List<double> v) => v.reduce((a, b) => a > b ? a : b);

/// Gráfico de linha (evolução de km/L e R$/km).
class SeriesLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String Function(double) tooltipFormat;
  final int axisDigits;

  const SeriesLineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.tooltipFormat,
    this.axisDigits = 2,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final minV = _min(values);
    final maxV = _max(values);
    final range = maxV - minV;
    final pad = range == 0 ? math.max(maxV * 0.1, 0.1) : range * 0.2;
    final minY = math.max(0.0, minV - pad);
    final maxY = maxV + pad;

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: math.max(values.length - 1, 1).toDouble(),
            minY: minY,
            maxY: maxY,
            titlesData: _titles(
              labels: labels,
              axisDigits: axisDigits,
              leftInterval: (maxY - minY) / 4,
            ),
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          tooltipFormat(s.y),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < values.length; i++)
                    FlSpot(i.toDouble(), values[i]),
                ],
                isCurved: false,
                barWidth: 3,
                color: color,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: color.withAlpha(40)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gráfico de barras (valor de cada abastecimento).
class SeriesBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String Function(double) tooltipFormat;
  final int axisDigits;

  const SeriesBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.tooltipFormat,
    this.axisDigits = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final maxV = _max(values);
    final maxY = maxV <= 0 ? 1.0 : maxV * 1.2;
    final barWidth = values.length > 20
        ? 5.0
        : values.length > 10
            ? 9.0
            : 16.0;

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8),
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            titlesData: _titles(
              labels: labels,
              axisDigits: axisDigits,
              leftInterval: maxY / 4,
            ),
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                  tooltipFormat(rod.toY),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < values.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i],
                      width: barWidth,
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
