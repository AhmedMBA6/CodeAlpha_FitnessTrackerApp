import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyDurationLineChart extends StatelessWidget {
  final List<dynamic> weeklySummaries;
  const WeeklyDurationLineChart({required this.weeklySummaries, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: _getMaxY(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeklySummaries.length) return const SizedBox.shrink();
                  final date = weeklySummaries[index].date;
                  return Text(_weekdayLabel(date));
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(weeklySummaries.length, (i) {
                final summary = weeklySummaries[i];
                return FlSpot(i.toDouble(), summary.totalDuration.toDouble());
              }),
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    final max = weeklySummaries.map((s) => s.totalDuration).fold<int>(0, (prev, el) => el > prev ? el : prev);
    return max < 60 ? 60 : (max * 1.2);
  }

  String _weekdayLabel(DateTime date) {
    return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
  }
} 