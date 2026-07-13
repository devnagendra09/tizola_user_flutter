import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void showGpsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Turn on Location'),
      content: const Text(
        'GPS is turned off. Please enable location services to continue.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await Geolocator.openLocationSettings();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: const Text('Open Settings'),
          ),
        ),
      ],
    ),
  );
}
