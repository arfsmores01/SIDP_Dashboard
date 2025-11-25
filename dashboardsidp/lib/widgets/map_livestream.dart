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
  Marker? _rpiMarker;

  // Firebase references
  final DatabaseReference gpsRef = FirebaseDatabase.instance.ref("gpsDB");
  final DatabaseReference liveStreamRef =
      FirebaseDatabase.instance.ref("liveStreamDB");

  // Live stream frame
  Uint8List? _frameBytes;

  // Control update rate to avoid excessive rebuilds
  int _lastUpdate = 0;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(3.1390, 101.6869), // Kuala Lumpur
    zoom: 18.0,
  );

  @override
  void initState() {
    super.initState();
    _listenToFirebaseGPS();
    _listenToFirebaseLiveStream();
  }

  /// Listen to GPS data and update marker
  void _listenToFirebaseGPS() {
    gpsRef.onValue.listen((event) async {
      if (event.snapshot.value == null) return;

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      final lat = (data["latitude"] as num).toDouble();
      final lng = (data["longitude"] as num).toDouble();
      final newPos = LatLng(lat, lng);

      final controller = await _mapController.future;

      // Animate camera smoothly
      controller.animateCamera(CameraUpdate.newLatLng(newPos));

      // Update or create marker
      setState(() {
        if (_rpiMarker == null) {
          _rpiMarker = Marker(
            markerId: const MarkerId("rpi"),
            position: newPos,
            infoWindow: const InfoWindow(title: "Raspberry Pi"),
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

  /// Listen to live stream frames
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Google Map Card
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 400,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                markers: _markers,
                onMapCreated: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Firebase Live Stream Card
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