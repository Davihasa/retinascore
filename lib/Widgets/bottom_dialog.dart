import 'package:flutter/material.dart';

class BottomDialog extends StatelessWidget {
  const BottomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  // Future<void> openBottomDialog(BuildContext context) async {
  //   await fetchImagensClassificadas();
  //   if (mounted) {
  //     return showDialog(
  //       context: context,
  //       barrierColor: Colors.black54,
  //       barrierDismissible: true,
  //       builder: (BuildContext context) {
  //         return PopScope(
  //           canPop: true,
  //           onPopInvokedWithResult: (didPop, result) async {
  //             if (didPop) {
  //               await Future.delayed(const Duration(milliseconds: 125));
  //             }
  //           },
  //           child: Align(
  //             alignment: Alignment.bottomCenter,
  //             child: FractionallySizedBox(
  //               heightFactor: 0.8,
  //               widthFactor: 1.0,
  //               child: Material(
  //                 elevation: 8,
  //                 borderRadius: BorderRadius.vertical(
  //                   top: Radius.circular(24),
  //                   bottom: Radius.circular(24),
  //                 ),
  //                 color: Colors.white,
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     children: [
  //                       SizedBox(height: 16),
  //                       Text(
  //                         "Imagens Avaliadas",
  //                         style: TextStyle(
  //                           fontSize: 18,
  //                           color: AppColors.primaryColor,
  //                         ),
  //                       ),
  //                       SizedBox(height: 20),
  //                       Expanded(
  //                         child: SingleChildScrollView(
  //                           child: Column(
  //                             children: [
  //                               ...imagensClassificadas.map((imageResult) {
  //                                 return ShowImageData(
  //                                   imageClassifyingResult: imageResult,
  //                                 );
  //                               }),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }
}