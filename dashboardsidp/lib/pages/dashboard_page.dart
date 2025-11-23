import 'package:flutter/material.dart';
import '../../widgets/status_cards.dart';
import '../../widgets/map_livestream.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 13, 125, 223),
        toolbarHeight: 80,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 50,
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Smart Navigation Visual Impaired Assistance Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            StatusCards(),
            SizedBox(height: 10),
            GPSLiveStreamView(),
          ],
        ),
      ),
    );
  }
}