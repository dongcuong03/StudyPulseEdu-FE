import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EvaluationChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const EvaluationChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    print(data);
    final int dat = data.where((e) => e['danhGia'] == 'Đạt').length;
    final int khongDat = data.length - dat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: dat.toDouble(),
                  color: Colors.teal,
                  title: '$dat',
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: khongDat.toDouble(),
                  color: Colors.orange,
                  title: '$khongDat',
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(color: Colors.teal, text: 'Đạt'),
              _buildLegendItem(color: Colors.orange, text: 'Không đạt'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
