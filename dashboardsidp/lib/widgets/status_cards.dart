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

          // Raspberry Pi status (static)
          _StatusCard(
            title: 'Raspberry Pi',
            value: 'ON',
            subtitle: 'Device Status',
            backgroundColor: const Color.fromARGB(255, 255, 228, 235),
            imagePath: 'assets/raspberrypi.png',
            iconSize: 90,
            iconColor: Colors.pink,
          ),

          // Camera status (static)
          _StatusCard(
            title: 'Camera',
            value: 'OFF',
            subtitle: 'Device Status',
            backgroundColor: const Color.fromARGB(255, 210, 230, 255),
            icon: Icons.videocam_outlined,
            iconSize: 100,
            iconColor: Colors.blue,
          ),
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
            backgroundColor: const Color.fromARGB(255, 210, 255, 210),
            icon: Icons.radar_outlined,
            iconColor: Color.fromARGB(255, 22, 100, 25),
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
          backgroundColor: const Color.fromARGB(255, 210, 255, 210),
          icon: Icons.radar_outlined,
          iconColor: Color.fromARGB(255, 22, 100, 25),
          iconSize: 100,
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
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
            imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: iconSize,
                    height: iconSize,
                    color: iconColor,
                  )
                : Icon(
                    icon,
                    size: iconSize,
                    color: iconColor,
                  ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 86, 86, 86),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
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
    );
  }
}