import 'dart:io';
import 'package:flutter/material.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Screens/image_data_page.dart';
import 'package:retinoscore/Services/image_classifier_service.dart';
import 'package:retinoscore/Styles/colors.dart';

class ShowImageData extends StatelessWidget {
  final ImageClassifyingResult imageClassifyingResult;

  const ShowImageData({super.key, required this.imageClassifyingResult});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryColor.withAlpha(64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageDataScreen(image: imageClassifyingResult),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor.withAlpha(40),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.file(
                    File(imageClassifyingResult.caminhoImagem),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PRIMEIRA LINHA DA QUALIDADE
                    Text(
                      imageClassifyingResult.qualidadeImagem != null
                          ? "Qualidade avaliada"
                          : "Qualidade não avaliada",
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            imageClassifyingResult.qualidadeImagem != null
                                ? AppColors.primaryColor
                                : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (imageClassifyingResult.qualidadeImagem != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Qualidade: ",
                                style: TextStyle(fontSize: 14),
                              ),
                              TextSpan(
                                text:
                                    imageClassifyingResult
                                        .qualidadeImagem!
                                        .label,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: getResultColor(
                                    imageClassifyingResult.qualidadeImagem,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // SETA DE NAVEGAÇÃO
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color? getResultColor(QualidadeImagem? qualidade) {
    if (qualidade == null) return null;
    switch (qualidade) {
      case QualidadeImagem.boa:
        return AppColors.goodColor;
      case QualidadeImagem.usavel:
        return AppColors.usableColor;
      case QualidadeImagem.rejeitada:
        return AppColors.rejectedColor;
    }
  }
}
