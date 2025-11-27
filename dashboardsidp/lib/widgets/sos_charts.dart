import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

//////////////////////////////////////////////////////////////////////
//  MODEL: SOS History Entry
//////////////////////////////////////////////////////////////////////

class SosHistoryEntry {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  SosHistoryEntry({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory SosHistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    return SosHistoryEntry(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

//////////////////////////////////////////////////////////////////////
//  DATABASE FETCH (REAL-TIME STREAM)
//////////////////////////////////////////////////////////////////////

Stream<List<SosHistoryEntry>> fetchSosHistory() {
  final ref = FirebaseDatabase.instance.ref().child("sosDB/history");

  return ref.onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return [];

    return data.values
        .map((e) => SosHistoryEntry.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  });
}

//////////////////////////////////////////////////////////////////////
//              LINE CHART (ANALYTICS)
//      Uses Firebase data to generate FlSpots
//////////////////////////////////////////////////////////////////////

class EmergencySosAnalyticsChart extends StatelessWidget {
  final List<SosHistoryEntry> history;

  const EmergencySosAnalyticsChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];

    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), (i + 1).toDouble()));
    }

    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: spots.isEmpty ? 6 : spots.last.x,
          minY: 0,
          maxY: spots.isEmpty ? 7 : spots.last.y + 1,

          gridData: const FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
          ),

          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              left: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
          ),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (history.isEmpty) return const SizedBox.shrink();

                  if (value.toInt() < 0 || value.toInt() >= history.length) {
                    return const SizedBox.shrink();
                  }

                  final dt = history[value.toInt()].timestamp;
                  final day = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dt.weekday - 1];

                  return Text(
                    day,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 4,
              isStrokeCapRound: true,
              spots: spots,

              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D7DDF).withValues(alpha: 0.5),
                  const Color(0xFF0D7DDF).withValues(alpha: 0.5),
                ],
              ),

              dotData: FlDotData(
                show: true,
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFF0D7DDF),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0D7DDF).withValues(alpha: 0.3),
                    const Color(0xFF0D7DDF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////
//              PIE CHART (SUMMARY)
//     Shows total SOS events dynamically
//////////////////////////////////////////////////////////////////////

class EmergencySosSummaryChart extends StatelessWidget {
  final List<SosHistoryEntry> history;

  const EmergencySosSummaryChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final total = history.length.toDouble();

    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: PieChart(
        PieChartData(
          centerSpaceRadius: 60,
          sectionsSpace: 4,
          sections: [
            PieChartSectionData(
              value: total,
              radius: 80,
              color: const Color(0xFF0D7DDF),
              title: '${total.toInt()} SOS',
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}