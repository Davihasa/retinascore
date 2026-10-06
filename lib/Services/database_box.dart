import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:retinoscore/Services/image_classifier_service.dart';

class DatabaseBox {
  late Box<ImageClassifyingResult> databaseBox;
  late Box<String> pathToWatch;

  Future<void> init() async {
    final dir = await getPublicDocumentsDirectory();
    await Hive.initFlutter(dir);
    try {
      Hive.registerAdapter(TipoImagemAdapter());
      Hive.registerAdapter(QualidadeImagemAdapter());
      Hive.registerAdapter(ImageClassifyingResultAdapter());
      debugPrint("Adapters registrados com sucesso");
    } catch (e) {
      debugPrint("Adapters já registrados");
    }

    databaseBox = await Hive.openBox<ImageClassifyingResult>('resultsBox');
    pathToWatch = await Hive.openBox<String>('pathToWatch');
    debugPrint("================Banco de dados carregado================");
  }

  Future<void> dispose() async {
    await databaseBox.close();
    await pathToWatch.close();
  }

  Future<String?> getPublicDocumentsDirectory() async {
    try {
      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0');

        if (await directory.exists()) {
          final documentsDir = Directory('${directory.path}/Documents/retinoscore_image_results');
          if (!await documentsDir.exists()) {
            await documentsDir.create(recursive: true);
          }
          return documentsDir.path;
        }

        final fallbackDir = await getExternalStorageDirectory();
        return fallbackDir?.path;
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao obter diretório público: $e");
      return null;
    }
  }
}
