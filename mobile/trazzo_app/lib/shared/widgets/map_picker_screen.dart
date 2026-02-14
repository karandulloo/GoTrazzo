import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Full-screen map to pick a location by dragging a marker.
/// Pops with [LatLng] on confirm, or null on cancel.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.title = 'Set location',
  });

  final double initialLatitude;
  final double initialLongitude;
  final String title;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _position;
  final Completer<GoogleMapController> _controllerCompleter = Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _position = LatLng(widget.initialLatitude, widget.initialLongitude);
  }

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('pin'),
          position: _position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _position = newPosition;
            });
          },
        ),
      };

  Future<void> _onMapCreated(GoogleMapController controller) async {
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
    }
  }

  void _confirm() {
    Navigator.of(context).pop(LatLng(_position.latitude, _position.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text('Confirm'),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _position,
          zoom: 14,
        ),
        markers: _markers,
        onMapCreated: _onMapCreated,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Drag the pin to set the exact location',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_position.latitude.toStringAsFixed(5)}, ${_position.longitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _confirm,
                child: const Text('Use this location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
