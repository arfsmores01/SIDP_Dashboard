import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

//////////////////////////////////////////////////////////////////////
//                     TIMESTAMP FORMATTER
//////////////////////////////////////////////////////////////////////

String formatTime(String ts) {
  try {
    final date = DateFormat("yyyy/MM/dd HH:mm:ss").parse(ts);
    return DateFormat("hh:mm a").format(date);
  } catch (_) {
    return "";
  }
}

//////////////////////////////////////////////////////////////////////
//                     CLEAN GRID STYLE
//////////////////////////////////////////////////////////////////////

FlGridData cleanGrid() {
  return FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: 1.0,
    getDrawingHorizontalLine: (value) => FlLine(
      color: Colors.grey.withValues(alpha: 0.15),
      strokeWidth: 1.0,
    ),
  );
}

//////////////////////////////////////////////////////////////////////
//                 OBJECT DETECTION HISTORY (AUTO SCALE)
//////////////////////////////////////////////////////////////////////
class ObjectDetectionChart extends StatelessWidget {
  const ObjectDetectionChart({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("objectDetectionDB/history");

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

      child: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Loading..."));
          }

          final raw = snapshot.data!.snapshot.value as Map;
          final List<Map> entries = [];

          raw.forEach((key, value) {
            if (value is Map && value.containsKey("timestamp")) {
              entries.add(value);
            }
          });

          entries.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));

          final trimmed = entries.length > 20
              ? entries.sublist(entries.length - 20)
              : entries;

          final List<FlSpot> spots = [];
          final List<String> labels = [];

          int index = 0;
          for (var entry in trimmed) {
            labels.add(formatTime(entry["timestamp"]));

            double count = entry["objects_detected"] is Map
                ? (entry["objects_detected"] as Map).length.toDouble()
                : 0.0;

            spots.add(FlSpot(index.toDouble(), count));
            index++;
          }

          // Auto Y scale
          double highest = spots.isNotEmpty
              ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b)
              : 5;

          double dynamicMaxY = highest <= 5 ? 5 : (highest + 1);

          return LineChart(
            LineChartData(
              minY: 0,
              maxY: dynamicMaxY,
              gridData: cleanGrid(),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final v = value.toInt();
                      if (v < 0 || v > dynamicMaxY) return const SizedBox.shrink();
                      return Text("$v", style: const TextStyle(fontSize: 12));
                    },
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox.shrink();
                      }

                      return Transform.rotate(
                        angle: -0.7,
                        child: Text(labels[idx], style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  color: const Color(0xFF0D7DDF),
                  dotData: FlDotData(show: false),

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
          );
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////
//              PROXIMITY PRIORITY CHART (4 FIXED LEVELS)
//////////////////////////////////////////////////////////////////////
class DistanceWaveformChart extends StatelessWidget {
  const DistanceWaveformChart({super.key});

  int getLevel(double distance) {
    if (distance < 50) return 1;
    if (distance < 100) return 2;
    if (distance < 200) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("ultrasonicDB/history");

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

      child: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Loading..."));
          }

          final raw = snapshot.data!.snapshot.value as Map;
          final List<Map> entries = [];

          raw.forEach((key, value) {
            if (value is Map && value.containsKey("timestamp")) {
              entries.add(value);
            }
          });

          entries.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));

          final trimmed = entries.length > 20
              ? entries.sublist(entries.length - 20)
              : entries;

          final List<FlSpot> spots = [];
          final List<String> labels = [];

          int index = 0;

          for (var entry in trimmed) {
            labels.add(formatTime(entry["timestamp"]));

            double dist = double.tryParse(entry["distance_cm"].toString()) ?? 0.0;
            int lvl = getLevel(dist);

            spots.add(FlSpot(index.toDouble(), lvl.toDouble()));
            index++;
          }

          return LineChart(
            LineChartData(
              minY: 1,
              maxY: 4,
              gridData: cleanGrid(),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 1:
                          return const Text("STOP", style: TextStyle(fontSize: 10));
                        case 2:
                          return const Text("WARNING", style: TextStyle(fontSize: 10));
                        case 3:
                          return const Text("CAUTION", style: TextStyle(fontSize: 10));
                        case 4:
                          return const Text("CLEAR", style: TextStyle(fontSize: 10));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox.shrink();
                      }

                      return Transform.rotate(
                        angle: -0.7,
                        child: Text(labels[idx], style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  color: Colors.redAccent,

                  dotData: const FlDotData(show: false),

                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.redAccent.withValues(alpha: 0.3),
                        Colors.redAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}