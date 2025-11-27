import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class GPSLiveStreamView extends StatefulWidget {
  const GPSLiveStreamView({super.key});

  @override
  State<GPSLiveStreamView> createState() => _GPSLiveStreamViewState();
}

class _GPSLiveStreamViewState extends State<GPSLiveStreamView> {
  // Google Map
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  Marker? _rpiMarker;

  // Firebase references
  final DatabaseReference gpsRef = FirebaseDatabase.instance.ref("gpsDB");
  final DatabaseReference liveStreamRef = FirebaseDatabase.instance.ref("liveStreamDB");
  final DatabaseReference sosRootRef = FirebaseDatabase.instance.ref("sosDB");

  // Live stream frame
  Uint8List? _frameBytes;

  // Control update rate to avoid excessive rebuilds
  int _lastUpdate = 0;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(3.1390, 101.6869), // Kuala Lumpur
    zoom: 18.0,
  );

  Timer? _pulseTimer;
  double _radius = 80;

  @override
  void initState() {
    super.initState();
    _listenToFirebaseGPS();
    _listenToFirebaseLiveStream();
    _listenToSOS();
  }

  // ============================================================
  // GPS MARKER UPDATER
  // ============================================================
  void _listenToFirebaseGPS() {
    gpsRef.onValue.listen((event) async {
      if (event.snapshot.value == null) return;

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      final lat = (data["latitude"] as num).toDouble();
      final lng = (data["longitude"] as num).toDouble();
      final newPos = LatLng(lat, lng);

      final controller = await _mapController.future;

      controller.animateCamera(CameraUpdate.newLatLng(newPos));

      setState(() {
        if (_rpiMarker == null) {
          _rpiMarker = Marker(
            markerId: const MarkerId("rpi"),
            position: newPos,
            infoWindow: const InfoWindow(title: "NaVIA LIVE"),
          );
          _markers.add(_rpiMarker!);
        } else {
          _rpiMarker = _rpiMarker!.copyWith(positionParam: newPos);
          _markers.removeWhere((m) => m.markerId == const MarkerId("rpi"));
          _markers.add(_rpiMarker!);
        }
      });
    });
  }

  // ============================================================
  // LIVE VIDEO UPDATER
  // ============================================================
  void _listenToFirebaseLiveStream() {
    liveStreamRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final base64Frame = data["frame"] as String?;
      if (base64Frame != null) {
        final frameBytes = base64Decode(base64Frame);

        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastUpdate > 180) {
          setState(() {
            _frameBytes = frameBytes;
          });
          _lastUpdate = now;
        }
      }
    });
  }

  // ============================================================
  // SOS LISTENER FOR ACTIVE BOOLEAN
  // ============================================================
  void _listenToSOS() {
  sosRootRef.onValue.listen((event) async {
    if (!mounted) return;
    if (event.snapshot.value == null) return;

    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

    final bool isActive = data["Active"] ?? false;

    if (!isActive) {
      // STOP RIPPLE
      _pulseTimer?.cancel();
      setState(() => _circles.clear());
      return;
    }

    // If Active = true, ripple start
    if (data["latitude"] == null || data["longitude"] == null) return;

    final lat = (data["latitude"] as num).toDouble();
    final lng = (data["longitude"] as num).toDouble();
    final pos = LatLng(lat, lng);

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(pos));

    _startRipple(pos);
  });
}

  // ============================================================
  // RIPPLE ANIMATION
  // ============================================================
  void _startRipple(LatLng pos) {
    _pulseTimer?.cancel();
    _circles.clear();
    _radius = 80;

    _pulseTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        _radius += 25;
        if (_radius > 300) _radius = 80;

        _circles.clear();
        _circles.add(
          Circle(
            circleId: const CircleId("sos_ripple"),
            center: pos,
            radius: _radius,
            fillColor: Colors.red.withValues(alpha: 0.15),
            strokeColor: Colors.red.withValues(alpha: 0.4),
            strokeWidth: 2,
          ),
        );
      });
    });
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Google Map Card
        Expanded(
          child: Stack(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 400,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialPosition,
                    markers: _markers,
                    circles: _circles,
                    onMapCreated: (controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                    },
                  ),
                ),
              ),

              // ================= CLEAR SOS BUTTON ON MAP =================
              Positioned(
                right: 20,
                bottom: 20,
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseDatabase.instance.ref("sosDB").update({
                      "Active": false,
                      "latitude": null,
                      "longitude": null,
                      "timestamp": null,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "CLEAR SOS",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Live Stream Card
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: _frameBytes == null
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: Image.memory(
                      _frameBytes!,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}