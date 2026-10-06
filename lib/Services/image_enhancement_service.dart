import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:opencv_core/opencv.dart' as cv;

class EnhancementService {
  static Future<Uint8List> applyClahe(File fileImage) async {
    // Carrega a imagem e converte para matriz do opencv
    cv.Mat mat = cv.imread(fileImage.path);

    // Converte para YCrCb (melhor aplicar CLAHE só no canal de luminância)
    mat = cv.cvtColor(mat, cv.COLOR_BGR2YCrCb);

    // Divide os canais
    cv.VecMat channels = cv.split(mat);

    // Cria o objeto CLAHE
    cv.CLAHE clahe = cv.createCLAHE(clipLimit: 2.0, tileGridSize: (8, 8));

    // Aplica no canal Y (luminância)
    cv.Mat y = channels[0];
    cv.Mat yClahe = clahe.apply(y);

    // Substitui o canal Y pelo processado
    channels[0] = yClahe;

    // Junta novamente os canais
    mat = cv.merge(channels);

    // Converte de volta para BGR
    mat = cv.cvtColor(mat, cv.COLOR_YCrCb2BGR);

    // Codifica a imagem processada em PNG para exibir no Flutter
    Uint8List bytes = Uint8List.fromList(cv.imencode('.png', mat).$2);
    debugPrint("Imagem melhorada gerada");
    // Retorna bytes
    return bytes;
  }
}
