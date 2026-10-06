import 'package:flutter/material.dart';
import 'package:retinoscore/Services/activation_state_manager.dart';
import 'package:retinoscore/Widgets/pop_up_overlay.dart';
import 'Styles/colors.dart';
import 'Screens/permission_gate.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ActivationState())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        iconTheme: IconThemeData(color: AppColors.primaryColor),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        textTheme: ThemeData().textTheme.apply(
          bodyColor: AppColors.primaryFontColor,
          displayColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: PermissionGate(),
    );
  }
}

@pragma('vm:entry-point')
void overlayMain() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: PopUpOverlay()));
}
