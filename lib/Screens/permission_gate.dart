import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:retinoscore/Models/permissions_enum.dart';
import 'package:retinoscore/Screens/home_page.dart';
import 'package:retinoscore/Screens/permission_request_screen.dart';

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  Future<List<Permissions>> checkPermissions() async {
    List<Permissions> denied = [];

    final storageStatus = await Permission.manageExternalStorage.status;
    final overlayStatus = await FlutterOverlayWindow.isPermissionGranted();

    if (storageStatus != PermissionStatus.granted) {
      denied.add(Permissions.storageAcess);
    }
    if (!overlayStatus) {
      denied.add(Permissions.showOverlay);
    }

    return denied;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Permissions>>(
      future: checkPermissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final deniedPermissions = snapshot.data ?? [];
        final allGranted = deniedPermissions.isEmpty;

        return allGranted
            ? HomePage()
            : PermissionRequestScreen(deniedPermissions: deniedPermissions);
      },
    );
  }
}
