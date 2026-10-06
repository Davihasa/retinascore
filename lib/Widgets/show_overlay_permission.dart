import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:retinoscore/Styles/colors.dart';

class ShowOverlayPermission extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  const ShowOverlayPermission({super.key, required this.onPermissionGranted});

  @override
  State<ShowOverlayPermission> createState() => _ShowOverlayPermissionState();
}

class _ShowOverlayPermissionState extends State<ShowOverlayPermission> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkAndProceed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void checkAndProceed() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (granted) {
      widget.onPermissionGranted();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Usuário voltou da tela de configuração
      checkAndProceed();
    }
  }

  Future<void> requestOverlayPermission() async {
    await FlutterOverlayWindow.requestPermission();
    // Após o retorno, o fluxo continua no didChangeAppLifecycleState
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.layers_rounded, size: 125),
          const SizedBox(height: 75),
          Text(
            "Permitir sobreposição de tela",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1,
              color: AppColors.secondaryFontColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          const Text(
            "Para o funcionamento correto do app, é necessário sobrepor outros apps",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 150),
          ElevatedButton(
            onPressed: requestOverlayPermission,
            child: const Text("Permitir sobreposição"),
          ),
          const SizedBox(height: 5),
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
