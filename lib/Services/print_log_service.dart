import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class PrintLogService {
  /// Grava um log em um arquivo .txt dentro do [parentPath].
  /// Se o arquivo não existir, ele é criado automaticamente.
  static void printLogInTxt(String log, String parentPath) {
    try {
      // Define o caminho completo do arquivo (por exemplo: logs.txt)
      final filePath = path.join(parentPath, 'log_retinoscore.txt');
      final file = File(filePath);

      // Garante que o diretório existe
      if (!Directory(parentPath).existsSync()) {
        Directory(parentPath).createSync(recursive: true);
      }

      // Adiciona o log com quebra de linha
      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '[$timestamp]: $log\n';

      // Escreve o log (append = true para não sobrescrever)
      file.writeAsStringSync(logMessage, mode: FileMode.append, flush: true);

      debugPrint('Log gravado em $filePath');
    } catch (e) {
      debugPrint('Erro ao gravar log: $e');
    }
  }
}
