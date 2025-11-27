import 'package:flutter/material.dart';
import '../../widgets/analysis_charts.dart';

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

              const SizedBox(height: 20),

                // ======================================================
                //         UPDATED SUMMARY CARDS
                // ======================================================
                Row(
                  children: const [
                    Expanded(
                      child: AnalysisSummaryCard(
                        title: "CPU Temperature",
                        value: "0°C",
                      ),
                    ),
                    SizedBox(width: 16),

                    Expanded(
                      child: AnalysisSummaryCard(
                        title: "Objects Detected",
                        value: "0",
                      ),
                    ),
                    SizedBox(width: 16),

                    Expanded(
                      child: AnalysisSummaryCard(
                        title: "Proximity Alerts",
                        value: "0",
                      ),
                    ),
                    SizedBox(width: 16),

                    Expanded(
                      child: AnalysisSummaryCard(
                        title: "SOS Triggers",
                        value: "0",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ======================================================
                //                 ANALYTICS CHARTS
                // ======================================================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Emergency SOS Analytics",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          _ChartPlaceholder(text: "Emergency SOS Chart"),
                        ],
                      ),
                    ),

                    SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Emergency SOS Summary",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          _ChartPlaceholder(text: "Emergency SOS Events"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

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
                          SizedBox(
                            height: 400,
                            child: ObjectDetectionChart(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 20),

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
                          SizedBox(
                            height: 400,
                            child: DistanceWaveformChart(),
                          ),
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

///////////////////////////////////////////////////////////////
//                  SUMMARY CARD CONDITION
///////////////////////////////////////////////////////////////

class AnalysisSummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;

  const AnalysisSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  State<AnalysisSummaryCard> createState() => _AnalysisSummaryCardState();
}

class _AnalysisSummaryCardState extends State<AnalysisSummaryCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,

      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        scale: isHovered ? 1.05 : 1.0,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          
          height: 140,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              // Base shadow (always visible)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),

              // Additional hover shadow (only when hovered)
              if (isHovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
            ],
          ),

          child: Card(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 23),

                  Text(
                    widget.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
//                  CHART CONDITION
///////////////////////////////////////////////////////////////

class _ChartPlaceholder extends StatefulWidget {
  final String text;

  const _ChartPlaceholder({required this.text});

  @override
  State<_ChartPlaceholder> createState() => _ChartPlaceholderState();
}

class _ChartPlaceholderState extends State<_ChartPlaceholder> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),

      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        scale: isHovered ? 1.03 : 1.0,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,

          // 🔵 Same card style as summary cards
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              // Base shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),

              // Hover shadow
              if (isHovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
            ],
          ),

          child: Container(
            height: 250,
            width: double.infinity,
            padding: const EdgeInsets.all(20),

            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}