import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StatusCards extends StatelessWidget {
  const StatusCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        childAspectRatio: 2.8,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 25,
        children: [
          // Object Detection (Live)
          const _ObjectDetectionLiveCard(),

          // Ultrasonic (Live)
          const _UltrasonicLiveCard(),

          // Raspberry Pi status (live)
          const _RaspberryPiLiveCard(),

          // Camera status (live)
          const _CameraLiveCard(),
        ],
      ),
    );
  }
}

class _ObjectDetectionLiveCard extends StatelessWidget {
  const _ObjectDetectionLiveCard();

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("objectDetectionDB");

    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _StatusCard(
            title: 'Object Detection',
            value: '...',
            subtitle: 'Loading...',
            backgroundColor: const Color.fromARGB(255, 255, 245, 210),
            icon: Icons.camera_alt,
            iconColor: Colors.orange,
            iconSize: 100,
          );
        }

        final data =
            Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);

        final latestKey = data.keys.last;
        final latestEntry =
            Map<dynamic, dynamic>.from(data[latestKey] as Map);

        // Get list of objects_detected
        final objectsList =
            List<dynamic>.from(latestEntry["objects_detected"] ?? []);

        final detectedCount = objectsList.length;

        // Extract names from each object
        List<String> objectNamesList = objectsList.map((obj) {
          if (obj is Map && obj["name"] != null) return obj["name"].toString();
          return obj.toString();
        }).toList();

        // Limit display to first 3 objects, add "+N more" if needed
        String objectNamesDisplay;
        const int maxDisplay = 3;
        if (objectNamesList.length > maxDisplay) {
          final remaining = objectNamesList.length - maxDisplay;
          objectNamesDisplay =
              "${objectNamesList.take(maxDisplay).join(', ')}, +$remaining more";
        } else {
          objectNamesDisplay = objectNamesList.join(', ');
        }

        final timestamp = latestEntry["timestamp"] ?? "-";

        return _StatusCard(
          title: 'Object Detection',
          value: "$detectedCount",
          subtitle: "Object: $objectNamesDisplay\nUpdated: $timestamp",
          backgroundColor: const Color.fromARGB(255, 255, 245, 210),
          icon: Icons.camera_alt,
          iconColor: Colors.orange,
          iconSize: 100,
        );
      },
    );
  }
}

class _UltrasonicLiveCard extends StatelessWidget {
  const _UltrasonicLiveCard();

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("ultrasonicDB");

    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _StatusCard(
            title: 'Proximity Distance',
            value: '...',
            subtitle: 'Loading...',
            backgroundColor: const Color.fromARGB(255, 229, 204, 255),
            icon: Icons.radar_outlined,
            iconColor: const Color.fromARGB(255, 94, 20, 107),
            iconSize: 100,
          );
        }

        // Convert DB to map
        final data =
            Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);

        // Get last child
        final latestKey = data.keys.last;
        final latestEntry =
            Map<dynamic, dynamic>.from(data[latestKey] as Map);

        final distance = latestEntry["distance_cm"] ?? 0.0;
        final message = latestEntry["message"] ?? "-";
        final timestamp = latestEntry["timestamp"] ?? "-";

        return _StatusCard(
          title: 'Proximity Distance',
          value: "${distance.toStringAsFixed(2)} cm",
          subtitle: "Status: $message\nUpdated: $timestamp",
          backgroundColor: const Color.fromARGB(255, 229, 204, 255),
          icon: Icons.radar_outlined,
          iconColor: const Color.fromARGB(255, 94, 20, 107),
          iconSize: 100,
        );
      },
    );
  }
}

// Live Raspberry Pi card
class _RaspberryPiLiveCard extends StatelessWidget {
  const _RaspberryPiLiveCard();

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("deviceStatus/raspberryPi");

    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        String status = "OFF";

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          status = snapshot.data!.snapshot.value.toString().toUpperCase();
        }

        return _StatusCard(
          title: 'Raspberry Pi',
          value: status,
          subtitle: 'Device Status',
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          imagePath: 'assets/raspberrypi.png',
          iconSize: 90,
          iconColor: const Color.fromARGB(255, 0, 0, 0),
        );
      },
    );
  }
}

// Live Camera card
class _CameraLiveCard extends StatelessWidget {
  const _CameraLiveCard();

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("deviceStatus/camera");

    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        String status = "OFF";

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          status = snapshot.data!.snapshot.value.toString().toUpperCase();
        }

        return _StatusCard(
          title: 'Camera',
          value: status,
          subtitle: 'Device Status',
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          icon: Icons.videocam_outlined,
          iconSize: 100,
          iconColor: const Color.fromARGB(255, 0, 0, 0),
        );
      },
    );
  }
}

class _StatusCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color backgroundColor;
  final IconData? icon;
  final String? imagePath;
  final Color iconColor;
  final double iconSize;

  const _StatusCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.imagePath,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.iconSize = 36,
  }) : assert(icon != null || imagePath != null,
              'Either icon or imagePath must be provided');

  @override
  State<_StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<_StatusCard> {
  bool isHovered = false;
  
  Color dynamicBackground(String title, String value) {
  // Only Raspberry Pi & Camera use dynamic background
  if (title == "Raspberry Pi" || title == "Camera") {
    if (value.toUpperCase() == "ON") {
      return const Color.fromARGB(255, 105, 255, 143); // bright green
    } else if (value.toUpperCase() == "OFF") {
      return const Color.fromARGB(255, 255, 107, 107); // bright red
    }
  }

  // default background from widget
  return widget.backgroundColor;
}

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,

      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: isHovered ? 1.03 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Card(
            color: dynamicBackground(widget.title, widget.value),
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.imagePath != null
                      ? Image.asset(
                          widget.imagePath!,
                          width: widget.iconSize,
                          height: widget.iconSize,
                          color: widget.iconColor,
                        )
                      : Icon(
                          widget.icon,
                          size: widget.iconSize,
                          color: widget.iconColor,
                        ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.value,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 39, 39, 39),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}