import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyChart extends StatelessWidget {
  final List<dynamic> weeklySummaries;
  const WeeklyChart({required this.weeklySummaries, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final summary = weeklySummaries[group.x.toInt()];
                return BarTooltipItem(
                  '${_weekdayLabel(summary.date)}\n'
                  '${rod.toY.toStringAsFixed(0)} cal',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
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
          barGroups: List.generate(weeklySummaries.length, (i) {
            final summary = weeklySummaries[i];
            final isToday = summary.date.day == DateTime.now().day &&
                            summary.date.month == DateTime.now().month &&
                            summary.date.year == DateTime.now().year;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: summary.totalCalories,
                  color: isToday ? Colors.green : Colors.orange,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              showingTooltipIndicators: [0],
            );
          }),
        ),
      ),
    );
  }

  double _getMaxY() {
    final max = weeklySummaries.map((s) => s.totalCalories).fold<double>(0, (prev, el) => el > prev ? el : prev);
    return max < 100 ? 100 : (max * 1.2);
  }

  String _weekdayLabel(DateTime date) {
    // Short weekday label, e.g., 'Mon'
    return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
  }
} 