import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Styles/colors.dart';
import 'package:retinoscore/Widgets/show_pacient_data.dart';

class HistoricPageByPacient extends StatefulWidget {
  const HistoricPageByPacient({super.key});

  @override
  State<HistoricPageByPacient> createState() => _HistoricPageByPacientState();
}

class _HistoricPageByPacientState extends State<HistoricPageByPacient> {
  List<ImageClassifyingResult> imagensClassificadas = [];
  bool isFetchingImages = false;
  Map<String, List<ImageClassifyingResult>> imagensPorPaciente = {};

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
    imagensPorPaciente = agruparPorPaciente(imagensClassificadas);
    setState(() {
      isFetchingImages = false;
    });
  }

  Map<String, List<ImageClassifyingResult>> agruparPorPaciente(
    List<ImageClassifyingResult> resultados,
  ) {
    final Map<String, List<ImageClassifyingResult>> mapa = {};

    for (final r in resultados) {
      final paciente = r.paciente;
      if (!mapa.containsKey(paciente)) {
        mapa[paciente] = [];
      }
      mapa[paciente]!.add(r);
    }
    return mapa;
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
              : imagensPorPaciente.isEmpty
              ? Center(child: Text("Histórico vazio"))
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(13, 30, 13, 0) ,
                itemCount: imagensPorPaciente.length,
                itemBuilder: (context, index) {
                  final paciente = imagensPorPaciente.keys.elementAt(index);
                  final imagens = imagensPorPaciente[paciente]!;
                  return ShowPacientData(
                    paciente: paciente,
                    imagensClassificadas: imagens,
                  );
                },
              ),
    );
  }
}
