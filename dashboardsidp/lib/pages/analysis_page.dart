import 'package:flutter/material.dart';
import '../../widgets/analysis_charts.dart';
import '../../widgets/sos_charts.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

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
              Icons.settings_system_daydream_rounded,
              color: Colors.white,
              size: 50,
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'System Analysis',
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

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),
                const Text(
                  "System Summary",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Real-time performance monitoring and usage statistics",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                // ======================================================
                //                SOS RECENT EVENTS (FULL WIDTH)
                // ======================================================
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Recent SOS Events",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 400, child: SosHistoryList()),
                  ],
                ),

                const SizedBox(height: 40),

                // ======================================================
                //              OBJECT DETECTION & PROXIMITY
                // ======================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Object Detection History",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          SizedBox(height: 400, child: ObjectDetectionChart()),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Proximity Event History",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          SizedBox(height: 400, child: DistanceWaveformChart()),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}