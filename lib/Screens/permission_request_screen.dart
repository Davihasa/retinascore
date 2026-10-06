import 'package:flutter/material.dart';
import 'package:retinoscore/Models/permissions_enum.dart';
import 'package:retinoscore/Screens/home_page.dart';
import 'package:retinoscore/Styles/colors.dart';
import 'package:retinoscore/Widgets/show_overlay_permission.dart';
import 'package:retinoscore/Widgets/show_storage_acess_permission.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PermissionRequestScreen extends StatefulWidget {
  final List<Permissions> deniedPermissions;
  const PermissionRequestScreen({super.key, required this.deniedPermissions});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  final pageController = PageController();
  final List<Widget> permissionPages = [];
  late Widget pageView;

  void addPermissionPages() {
    if (widget.deniedPermissions.contains(Permissions.storageAcess)) {
      permissionPages.add(
        ShowStorageAcessPermission(onPermissionGranted: goToNextPage),
      );
    }
    if (widget.deniedPermissions.contains(Permissions.showOverlay)) {
      permissionPages.add(
        ShowOverlayPermission(onPermissionGranted: goToNextPage),
      );
    }
  }

  void goToNextPage() {
    if (pageController.hasClients &&
        pageController.page! < permissionPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    addPermissionPages();
    pageView = PageView(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      children: permissionPages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: pageView),
            SmoothPageIndicator(
              controller: pageController,
              count: permissionPages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primaryColor,
                dotHeight: 16,
                dotWidth: 16,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
