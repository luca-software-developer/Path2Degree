import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path2degree/utils/chart_colors.dart';

class Chart extends StatefulWidget {
  const Chart({super.key, required this.voti, required this.colors});

  final List<double> voti;
  final List<Color> colors;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.618,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
        child: LineChart(
          mainData(widget.voti, widget.colors),
        ),
      ),
    );
  }
}

Widget leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );
  String text;
  if (value.toInt() % 2 == 0) {
    text = value.toInt().toString();
  } else {
    return Container();
  }
  return Text(text, style: style, textAlign: TextAlign.left);
}

LineChartData mainData(List<double> voti, List<Color> colors) {
  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: ChartColors.mainGridLineColor,
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: ChartColors.mainGridLineColor,
          strokeWidth: 1,
        );
      },
    ),
    titlesData: const FlTitlesData(
      show: true,
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: leftTitleWidgets,
          reservedSize: 42,
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d)),
    ),
    minY: 18,
    maxY: 30,
    lineBarsData: voti.isEmpty
        ? []
        : [
            LineChartBarData(
              spots: voti
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList(),
              gradient: LinearGradient(
                colors: colors,
              ),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors:
                      colors.map((color) => color.withOpacity(0.3)).toList(),
                ),
              ),
            ),
          ],
  );
}
