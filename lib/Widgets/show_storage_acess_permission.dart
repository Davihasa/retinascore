import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:retinoscore/Styles/colors.dart';

class ShowStorageAcessPermission extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  const ShowStorageAcessPermission({
    super.key,
    required this.onPermissionGranted,
  });

  @override
  State<ShowStorageAcessPermission> createState() =>
      _ShowStorageAcessPermissionState();
}

class _ShowStorageAcessPermissionState
    extends State<ShowStorageAcessPermission> {
  Future<void> requestStorageAcess() async {
    if (await Permission.storage.isDenied) {
      final status = await Permission.manageExternalStorage.request();
      if (status == PermissionStatus.granted) {
        widget.onPermissionGranted();
      }
    } else if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();

    goToNextPageIfGranted();
  }

  void goToNextPageIfGranted() async {
    if (await Permission.storage.isGranted) {
      widget.onPermissionGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Icon(Icons.sd_storage_rounded, size: 125),
          SizedBox(height: 75),
          Text(
            "Permitir acesso aos arquivos",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1,
              color: AppColors.secondaryFontColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25),
          Text(
            "Para o funcionamento correto do app, é necessário acessar o armazenamento do dispositivo",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 150),
          ElevatedButton(
            onPressed: requestStorageAcess,
            child: const Text("Permitir acesso aos arquivos"),
          ),
          SizedBox(height: 5),
          TextButton(
            onPressed: () {},
            child: Text(
              "Talvez mais tarde",
              style: TextStyle(color: AppColors.fontColor),
            ),
          ),
        ],
      ),
    );
  }
}
