import 'dart:io';

import 'package:flutter/material.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Services/image_classifier_service.dart';
import 'package:retinoscore/Styles/colors.dart';
import 'package:intl/intl.dart';

class ImageDataScreen extends StatefulWidget {
  final ImageClassifyingResult image;
  const ImageDataScreen({super.key, required this.image});

  @override
  State<ImageDataScreen> createState() => _ImageDataScreenState();
}

class _ImageDataScreenState extends State<ImageDataScreen> {
  late DateTime data = widget.image.dataClassificacao;
  late String caminhoImagem = widget.image.caminhoImagem;
  late String? caminhoImagemMelhorada = widget.image.caminhoImagemMelhorada;
  late QualidadeImagem? qualidade = widget.image.qualidadeImagem;
  late QualidadeImagem? qualidadeImagemMelhorada =
      widget.image.qualidadeImagemMelhorada;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteFontColor,
          title: Text("Dados da imagem", textAlign: TextAlign.center),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 25, 13, 0),
                child: Card(
                  color: AppColors.primaryColor,
                  child: ListTile(
                    title: Text(
                      "Paciente: ${widget.image.paciente}\nData da aquisição: ${DateFormat('dd/MM/yyyy').format(data)}",
                      style: TextStyle(
                        color: AppColors.whiteFontColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 25, 13, 0),
                child: Card(
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 25, 0, 16),
                      child: Text(
                        "Imagem original",
                        textAlign: TextAlign.center,
                        style: TextStyle(),
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image(
                            image: FileImage(File(caminhoImagem)),
                            width: 300,
                          ),
                        ),
                        ...(qualidade == null
                            ? [Text("Qualidade: Não avaliada")]
                            : [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tipo da imagem: ${widget.image.tipoImagem.label}",
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(text: "Qualidade: "),
                                            TextSpan(
                                              text: qualidade!.label,
                                              style: TextStyle(
                                                color: getResultColor(
                                                  qualidade,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.image.tipoImagem != TipoImagem.noEye)
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 25, 13, 0),
                  child: Card(
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 25, 0, 16),
                        child: Text(
                          "Imagem melhorada",
                          textAlign: TextAlign.center,
                          style: TextStyle(),
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          ...(caminhoImagemMelhorada == null
                              ? [Text("Imagem melhorada não disponível")]
                              : [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image(
                                    image: FileImage(
                                      File(caminhoImagemMelhorada!),
                                    ),
                                    width: 300,
                                  ),
                                ),
                              ]),

                          ...(qualidadeImagemMelhorada == null
                              ? [Text("Qualidade: Não avaliada")]
                              : [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(text: "Qualidade: "),
                                          TextSpan(
                                            text:
                                                qualidadeImagemMelhorada!.label,
                                            style: TextStyle(
                                              color: getResultColor(
                                                qualidadeImagemMelhorada,
                                              ),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 30),
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
