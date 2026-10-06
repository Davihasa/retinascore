import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Styles/colors.dart';
import 'package:retinoscore/Widgets/show_image_data.dart';

class HistoricPage extends StatefulWidget {
  const HistoricPage({super.key});

  @override
  State<HistoricPage> createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage> {
  List<ImageClassifyingResult> imagensClassificadas = [];
  bool isFetchingImages = false;

  @override
  void initState() {
    super.initState();
    fetchImagensClassificadas();
  }

  Future<void> fetchImagensClassificadas() async {
    setState(() {
      isFetchingImages = true;
    });
    await Hive.close();
    Box<ImageClassifyingResult> databaseBox =
        await Hive.openBox<ImageClassifyingResult>('resultsBox');
    final futures = databaseBox.values.map((result) async {
      try {
        final file = File(result.caminhoImagem);
        if (await file.exists()) {
          return result;
        } else {
          databaseBox.delete(result.key);
        }
        return null;
      } catch (e) {
        return null;
      }
    });
    final results = await Future.wait(futures);
    imagensClassificadas = results.whereType<ImageClassifyingResult>().toList();
    imagensClassificadas.sort((a, b) {
      if (a.dataClassificacao.isAfter(b.dataClassificacao)) {
        return -1;
      } else if (b.dataClassificacao.isAfter(a.dataClassificacao)) {
        return 1;
      } else {
        return 0;
      }
    });
    setState(() {
      isFetchingImages = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteFontColor,
        title: Text("Histórico", textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        centerTitle: true,
      ),
      body:
          isFetchingImages
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : Center(
                child:
                    imagensClassificadas.isEmpty
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Center(child: Text("Histórico vazio"))],
                        )
                        : Padding(
                          padding: const EdgeInsets.fromLTRB(13, 30, 13, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                imagensClassificadas.map((imageResult) {
                                  return ShowImageData(
                                    imageClassifyingResult: imageResult,
                                  );
                                }).toList(),
                          ),
                        ),
              ),
    );
  }
}
