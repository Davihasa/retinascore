import 'package:flutter/material.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Styles/colors.dart';
import 'package:retinoscore/Widgets/show_image_data.dart';

class AcquisitionsFromPacient extends StatefulWidget {
  final List<ImageClassifyingResult> imagensClassificadas;
  const AcquisitionsFromPacient({
    super.key,
    required this.imagensClassificadas,
  });

  @override
  State<AcquisitionsFromPacient> createState() =>
      _AcquisitionsFromPacientState();
}

class _AcquisitionsFromPacientState extends State<AcquisitionsFromPacient> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteFontColor,
        title: Text(
          "Aquisições de ${widget.imagensClassificadas.isNotEmpty ? widget.imagensClassificadas.first.paciente : ''}",
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        centerTitle: true,
      ),
      body:
          widget.imagensClassificadas.isEmpty
              ? Center(child: Text("Histórico vazio"))
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(13, 30, 13, 0),
                itemCount: widget.imagensClassificadas.length,
                itemBuilder: (context, index) {
                  return ShowImageData(
                    imageClassifyingResult: widget.imagensClassificadas[index],
                  );
                },
              ),
    );
  }
}
