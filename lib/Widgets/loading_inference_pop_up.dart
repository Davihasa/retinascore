import 'package:flutter/material.dart';
import 'package:retinoscore/Styles/colors.dart';

class LoadingInferencePopUp extends StatelessWidget {
  const LoadingInferencePopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: 30.0,
            child: IconButton(
              icon: Icon(Icons.auto_awesome, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
