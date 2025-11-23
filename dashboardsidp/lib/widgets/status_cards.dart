import 'package:flutter/material.dart';

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
          _StatusCard(
            title: 'Object Detection',
            value: '5',
            subtitle: 'Last updated 1 min ago',
            backgroundColor: Color.fromARGB(255, 255, 245, 210), 
            icon: Icons.camera_alt,
            iconSize: 100,
            iconColor: Colors.orange,
          ),
          _StatusCard(
            title: 'Proximity Distance',
            value: '2.12 m',
            subtitle: 'Last updated 1 min ago',
            backgroundColor: Color.fromARGB(255, 210, 255, 210), 
            icon: Icons.radar_outlined,
            iconSize: 100,
            iconColor: const Color.fromARGB(255, 22, 100, 25),
          ),
          _StatusCard(
            title: 'Raspberry Pi',
            value: 'ON', // ON/OFF indicator
            subtitle: 'Device Status',
            backgroundColor: Color.fromARGB(255, 255, 228, 235),  
            imagePath: 'assets/raspberrypi.png',
            iconSize: 90,
            iconColor: Colors.pink,
          ),
          _StatusCard(
            title: 'Camera',
            value: 'OFF', // ON/OFF indicator
            subtitle: 'Device Status',
            backgroundColor: Color.fromARGB(255, 210, 230, 255),
            icon: Icons.videocam_outlined,
            iconSize: 100,
            iconColor: Colors.blue,
          ),
        ],
      ),
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
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}