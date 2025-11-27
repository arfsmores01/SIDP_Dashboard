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

    return StreamBuilder(
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

        // ================================
        //       AUTO-SCALE Y-axis
        // ================================

        double highest = 0;
        if (spots.isNotEmpty) {
          highest = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        }

        // If highest <= 5 → maxY = 5
        // If highest > 5 → maxY = highest + 1
        double dynamicMaxY = highest <= 5 ? 5 : (highest + 1);

        return RepaintBoundary(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: dynamicMaxY,
              gridData: cleanGrid(),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),

                // -----------------------
                //       CLEAN Y-AXIS
                // -----------------------
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final v = value.toInt();
                      if (v < 0) return const SizedBox.shrink();

                      // Only show integers up to the auto-scale maxY
                      if (v <= dynamicMaxY) {
                        return Text(
                          v.toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // ------------------------
                //       CLEAN X-AXIS
                // ------------------------
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox.shrink();
                      }

                      return Transform.rotate(
                        angle: -0.7,
                        child: Text(
                          labels[idx],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  barWidth: 2.5,
                  color: Colors.blueAccent,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//////////////////////////////////////////////////////////////////////
//              PROXIMITY PRIORITY CHART (4 FIXED LEVELS)
//////////////////////////////////////////////////////////////////////

class DistanceWaveformChart extends StatelessWidget {
  const DistanceWaveformChart({super.key});

  int getLevel(double distance) {
    if (distance < 50) return 1; // Stop
    if (distance < 100) return 2; // Warning
    if (distance < 200) return 3; // Caution
    return 4; // Clear
  }

  Color getLevelColor(int lvl) {
    switch (lvl) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.green;
    }
    return Colors.grey;
  }

  String getLevelLabel(int lvl) {
    switch (lvl) {
      case 1:
        return "Stop";
      case 2:
        return "Warning";
      case 3:
        return "Caution";
      case 4:
        return "Clear";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("ultrasonicDB/history");

    return StreamBuilder(
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

          double dist =
              double.tryParse(entry["distance_cm"].toString()) ?? 0.0;

          int lvl = getLevel(dist);

          spots.add(FlSpot(index.toDouble(), lvl.toDouble()));
          index++;
        }

        return RepaintBoundary(
          child: LineChart(
            LineChartData(
              minY: 1,
              maxY: 4,
              gridData: cleanGrid(),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final lvl = value.toInt();
                      if (lvl < 1 || lvl > 4) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        getLevelLabel(lvl),
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox.shrink();
                      }

                      return Transform.rotate(
                        angle: -0.7,
                        child: Text(
                          labels[idx],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  barWidth: 3,
                  color: Colors.redAccent,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}