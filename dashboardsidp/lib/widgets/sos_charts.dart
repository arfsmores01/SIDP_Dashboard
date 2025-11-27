import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

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
//                     CLEAN GRID STYLE (unused but keep)
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
//                    SOS HISTORY LIST  (HOVER ENABLED)
//////////////////////////////////////////////////////////////////////

class SosHistoryList extends StatelessWidget {
  const SosHistoryList({super.key});

  Future<String> _getAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final p = placemarks.first;

      return "${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}";
    } catch (e) {
      return "Address unavailable";
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("sosDB/history");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Loading..."));
          }

          final raw = snapshot.data!.snapshot.value as Map;

          List<Map> entries = [];
          raw.forEach((key, value) {
            if (value is Map && value.containsKey("timestamp")) {
              entries.add(value);
            }
          });

          entries.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));

          // 👉 HOVER STATES LIST
          List<ValueNotifier<bool>> isHovering =
              List.generate(entries.length, (_) => ValueNotifier(false));

          return SizedBox(
            height: 300,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final item = entries[index];

                final tsString = item["timestamp"];
                final dt = DateFormat("yyyy/MM/dd HH:mm:ss").parse(tsString);

                final date = DateFormat("dd MMM yyyy").format(dt);
                final time = DateFormat("hh:mm a").format(dt);

                String duration = "—";
                if (index < entries.length - 1) {
                  final prev = DateFormat("yyyy/MM/dd HH:mm:ss")
                      .parse(entries[index + 1]["timestamp"]);

                  final diff = (prev.difference(dt)).inSeconds.abs();

                  duration = "$diff sec";
                }

                final double lat =
                    double.tryParse(item["latitude"].toString()) ?? 0.0;
                final double lng =
                    double.tryParse(item["longitude"].toString()) ?? 0.0;

                return FutureBuilder(
                  future: _getAddress(lat, lng),
                  builder: (context, snap) {
                    final address =
                        snap.data?.toString() ?? "Address unavailable";

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => isHovering[index].value = true,
                      onExit: (_) => isHovering[index].value = false,

                      child: ValueListenableBuilder<bool>(
                        valueListenable: isHovering[index],
                        builder: (context, hovered, _) {
                          return AnimatedScale(
                            scale: hovered ? 1.0001 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,

                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 180),
                              curve: Curves.easeOut,

                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              margin:
                                  const EdgeInsets.only(bottom: 12),

                              decoration: BoxDecoration(
                                color: hovered
                                    ? Colors.blueAccent.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(
                                        hovered ? 0.18 : 0.10),
                                    blurRadius:
                                        hovered ? 18 : 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // DATE + TIME ROW
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(time,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      Text(date,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54)),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // COORDINATES
                                  Text("Latitude: $lat  |  Longitude: $lng",
                                      style:
                                          const TextStyle(fontSize: 13)),

                                  const SizedBox(height: 6),

                                  // DURATION
                                  Text("Duration: $duration",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87)),

                                  const SizedBox(height: 6),

                                  // ADDRESS
                                  Text(
                                    "Location: $address",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////
//                         BOX STYLE
//////////////////////////////////////////////////////////////////////

BoxDecoration _box() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}