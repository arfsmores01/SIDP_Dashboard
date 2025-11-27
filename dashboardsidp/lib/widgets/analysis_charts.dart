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
//      OBJECT DETECTION HISTORY (AUTO-SCALE Y AXIS, 20 ENTRIES)
//////////////////////////////////////////////////////////////////////
class ObjectDetectionChart extends StatelessWidget {
  const ObjectDetectionChart({super.key});

  // Smart auto-scaling to nice round numbers
  double autoScaleY(int maxValue) {
    if (maxValue <= 5) return 5;
    if (maxValue <= 10) return 10;
    if (maxValue <= 20) return 20;
    if (maxValue <= 40) return 40;
    if (maxValue <= 80) return 80;
    if (maxValue <= 100) return 100;
    return (maxValue * 1.2).ceilToDouble(); // fallback
  }

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
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("No data"));
          }

          final raw = snapshot.data!.snapshot.value as Map;

          // Sort by timestamp
          final entries = raw.entries.toList()
            ..sort((a, b) => a.value["timestamp"].toString().compareTo(
                  b.value["timestamp"].toString(),
                ));

          // Only last 20 entries
          final trimmed = entries.length > 20
              ? entries.sublist(entries.length - 20)
              : entries;

          List<FlSpot> spots = [];
          List<String> labels = [];

          int index = 0;
          int maxDetected = 0;

          for (var e in trimmed) {
            final row = e.value;

            // Count objects
            int count = 0;
            if (row["objects_detected"] != null) {
              final obj = row["objects_detected"];
              if (obj is Map) count = obj.length;
              if (obj is List) count = obj.where((x) => x != null).length;
            }

            if (count > maxDetected) maxDetected = count;

            // Timestamp label
            String label;
            try {
              final dt = DateFormat("yyyy/MM/dd HH:mm:ss").parse(row["timestamp"]);
              label = DateFormat("hh:mm a").format(dt);
            } catch (_) {
              label = "NA";
            }

            spots.add(FlSpot(index.toDouble(), count.toDouble()));
            labels.add(label);
            index++;
          }

          // Compute dynamic Y max
          final double yMax = autoScaleY(maxDetected);

          return LineChart(
            LineChartData(
              minY: 0,
              maxY: yMax,

              gridData: cleanGrid(),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: (yMax / 5).ceilToDouble(),
                    getTitlesWidget: (v, meta) {
                      return Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
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
                  color: Colors.greenAccent,

                  dotData: const FlDotData(show: false),

                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent.withValues(alpha: 0.3),
                        Colors.greenAccent.withValues(alpha: 0.0),
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