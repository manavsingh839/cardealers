import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../models/analytics_model.dart';

class LeadAnalyticsChart extends StatelessWidget {
  final DealerPerformanceStats stats;

  const LeadAnalyticsChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lead Acquisition Channels',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Customer enquiries, direct WhatsApp chats, and phone clicks',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${stats.totalCustomerInteractions} Total Leads',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String title;
                        switch (group.x) {
                          case 0:
                            title = 'Car Views';
                            break;
                          case 1:
                            title = 'WhatsApp Clicks';
                            break;
                          case 2:
                            title = 'Phone Calls';
                            break;
                          case 3:
                            title = 'Enquiries';
                            break;
                          case 4:
                            title = 'Converted';
                            break;
                          default:
                            title = '';
                        }
                        return BarTooltipItem(
                          '$title: ${rod.toY.toInt()}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String label = '';
                          switch (value.toInt()) {
                            case 0:
                              label = 'Views';
                              break;
                            case 1:
                              label = 'WhatsApp';
                              break;
                            case 2:
                              label = 'Calls';
                              break;
                            case 3:
                              label = 'Enquiries';
                              break;
                            case 4:
                              label = 'Converted';
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _barGroup(0, stats.carViews.toDouble(), AppColors.primaryLight),
                    _barGroup(1, stats.whatsappClicks.toDouble(), AppColors.whatsappDark),
                    _barGroup(2, stats.phoneClicks.toDouble(), AppColors.accent),
                    _barGroup(3, stats.totalEnquiries.toDouble(), AppColors.orange),
                    _barGroup(4, stats.convertedLeads.toDouble(), AppColors.emerald),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY() {
    double maxVal = stats.carViews.toDouble();
    if (maxVal < 10) maxVal = 10;
    return (maxVal * 1.25).ceilToDouble();
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
