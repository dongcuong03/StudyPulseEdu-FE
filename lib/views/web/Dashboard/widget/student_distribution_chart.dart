import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:study_pulse_edu/models/app/ClassStudentCountResponseDto.dart';

class StudentDistributionChart extends StatelessWidget {
  final List<ClassStudentCountResponseDto> data;

  const StudentDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Nếu không có dữ liệu thì trả về widget rỗng hoặc thông báo
    if (data.isEmpty) {
      return const Center(child: Text('Không có dữ liệu lớp học.'));
    }

    const Color barColor = Colors.blue;
    final double chartWidth = data.length * 70.0;

    final int maxStudentCount = data.map((e) => e.studentCount).reduce(max);
    const double maxBarHeight = 240;
    final double scaleFactor = maxBarHeight / (maxStudentCount + 5);

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 35),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (maxStudentCount + 5) * scaleFactor,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final item = data[group.x.toInt()];
                          return BarTooltipItem(
                            '${item.className}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: '${item.studentCount} học sinh',
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    barGroups: List.generate(
                      data.length,
                      (index) {
                        final item = data[index];
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: item.studentCount * scaleFactor,
                              color: barColor,
                              width: 30,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Transform.rotate(
                                  angle: -0.5,
                                  child: Text(
                                    data[index].className,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 10 * scaleFactor,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final realValue = (value / scaleFactor).round();
                            return Text(realValue.toString());
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide(color: Colors.black),
                        bottom: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Biểu đồ phân bố số học sinh theo lớp",
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
