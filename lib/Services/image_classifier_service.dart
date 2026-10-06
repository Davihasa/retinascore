import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:opencv_core/opencv.dart' as cv;
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Services/database_box.dart';
import 'package:retinoscore/Services/print_log_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path/path.dart' as path;

part 'image_classifier_service.g.dart';

class ClassifierModel {
  late Interpreter typeImageClassifier;
  late Interpreter qualityImageClassifier;
  late DatabaseBox hive;

  ClassifierModel();

  Future<void> init() async {
    try {
      qualityImageClassifier = await Interpreter.fromAsset(
        'assets/models/model.tflite',
      );
      var inputDetails = qualityImageClassifier.getInputTensor(0);
      debugPrint(
        "=====================Modelo de classificação da qualidade carregado===========================",
      );
      debugPrint('Shape esperado pelo modelo: ${inputDetails.shape}');
      debugPrint('Tipo esperado: ${inputDetails.type}');

      typeImageClassifier = await Interpreter.fromAsset(
        'assets/models/modeloClassificaTipoImagem.tflite',
      );
      inputDetails = typeImageClassifier.getInputTensor(0);
      debugPrint(
        "==============Modelo de classificação do tipo da imagem carregado========================",
      );
      debugPrint('Shape esperado pelo modelo: ${inputDetails.shape}');
      debugPrint('Tipo esperado: ${inputDetails.type}');
      hive = DatabaseBox();
      await hive.init();
      printModelInfo(qualityImageClassifier);
    } catch (e) {
      debugPrint("Erro ao carregar modelo: ${e.toString()}");
    }
  }

  Future<ImageClassifyingResult> reclassifyImageAndSave(
    String caminhoImagemOriginal,
    String caminhoImagemMelhorada,
  ) async {
    debugPrint("Melhorando imagem...");
    try {
      final imageResult = hive.databaseBox.get(caminhoImagemOriginal);

      if (imageResult == null) {
        throw Exception(
          'registro não encontrado no Hive para $caminhoImagemOriginal',
        );
      }

      final arquivoMelhorado = File(caminhoImagemMelhorada);

      if (imageResult.tipoImagem == TipoImagem.retina) {
        final inputTensor = await imageToTensor(arquivoMelhorado);
        final inputs = [inputTensor];

        var outputs = {
          0: List.generate(1, (_) => List.filled(3, 0.0)),
          1: List.generate(1, (_) => List.filled(1280, 0.0)),
        };

        qualityImageClassifier.runForMultipleInputs(inputs, outputs);
        debugPrint(outputs.toString());

        // Avalia o resultado
        final qualidadeImagem = avaliarImagem(outputs);
        imageResult.qualidadeImagemMelhorada = qualidadeImagem;
      } else {
        imageResult.qualidadeImagemMelhorada = QualidadeImagem.rejeitada;
      }

      // Atualiza o caminho da imagem melhorada
      imageResult.caminhoImagemMelhorada = caminhoImagemMelhorada;

      // Salva novamente no Hive
      hive.databaseBox.put(caminhoImagemOriginal, imageResult);
      await hive.databaseBox.flush();
      return imageResult;
    } catch (e) {
      PrintLogService.printLogInTxt(
        e.toString(),
        File(hive.databaseBox.path!).parent.path,
      );
      rethrow;
    }
  }

  Future<ImageClassifyingResult> classifyImageAndSave(File entryImage) async {
    String imagePath = entryImage.path;

    if (hive.databaseBox.get(imagePath) != null) {
      throw Exception("imagem já foi classificada");
    }
    if (imagePath.contains('_melhorada')) {
      throw Exception("imagem melhorada não deve ser classificada");
    }
    try {
      TipoImagem tipoImagem = await runTypeImageClassifier(entryImage);
      ImageClassifyingResult imageClassifyingResult = ImageClassifyingResult(
        qualidadeImagem: null,
        tipoImagem: tipoImagem,
        paciente: path.dirname(imagePath).split('/').last,
        caminhoImagem: imagePath,
        dataClassificacao: DateTime.now(),
        caminhoImagemMelhorada: null,
        qualidadeImagemMelhorada: null,
      );
      if (tipoImagem == TipoImagem.olho) {
        var inputTensor1 = await imageToTensor(entryImage);

        var inputs = [inputTensor1];

        var outputs = {
          0: List.generate(1, (_) => List.filled(3, 0.0)),
          1: List.generate(1, (_) => List.filled(1280, 0.0)),
        };
        qualityImageClassifier.runForMultipleInputs(inputs, outputs);

        debugPrint(outputs.toString());
        QualidadeImagem qualidadeImagem = avaliarImagem(outputs);
        imageClassifyingResult.qualidadeImagem = qualidadeImagem;
      } else if (tipoImagem != TipoImagem.noEye) {
        var inputTensor1 = await imageToTensor(entryImage);

        var inputs = [inputTensor1];

        var outputs = {
          0: List.generate(1, (_) => List.filled(3, 0.0)),
          1: List.generate(1, (_) => List.filled(1280, 0.0)),
        };
        qualityImageClassifier.runForMultipleInputs(inputs, outputs);

        debugPrint(outputs.toString());
        QualidadeImagem qualidadeImagem = avaliarImagem(outputs);
        imageClassifyingResult.qualidadeImagem = qualidadeImagem;
      } else {
        imageClassifyingResult.qualidadeImagem = QualidadeImagem.rejeitada;
      }
      hive.databaseBox.put(imagePath, imageClassifyingResult);
      await hive.databaseBox.flush();
      return imageClassifyingResult;
    } catch (e) {
      PrintLogService.printLogInTxt(
        e.toString(),
        File(hive.databaseBox.path!).parent.path,
      );
      rethrow;
    }
  }

  Future<List<List<List<Float32List>>>> imageToTensor(File imageInput) async {
    const int resizeMinSide = 256;
    const int cropSize = 224;

    // médias/desvios ImageNet
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    // --- 1. Carrega a imagem em Dart (image package) ---
    final rawBytes = await imageInput.readAsBytes();
    final img.Image? dartImage = img.decodeImage(rawBytes);
    if (dartImage == null) throw Exception("Falha ao decodificar imagem");

    // --- 2. Resize mantendo proporção---
    int w = dartImage.width;
    int h = dartImage.height;
    double scale = resizeMinSide / (w < h ? w : h);
    int newW = (w * scale).floor();
    int newH = (h * scale).floor();

    cv.Mat mat = cv.imread(imageInput.path);
    mat = cv.resize(mat, (newW, newH));

    // 3. Center-crop 299×299
    int startX = ((newW - cropSize) / 2).round();
    int startY = ((newH - cropSize) / 2).round();
    cv.Rect roi = cv.Rect(startX, startY, cropSize, cropSize);
    cv.Mat cropped = cv.Mat.fromMat(mat, roi: roi);
    mat.release();

    // 4. Usa blobFromImage para escalar 1/255, subtrair mean e swapRB (BGR→RGB)
    cv.Mat blob = cv.blobFromImage(
      cropped,
      scalefactor: 1 / 255.0,
      size: (cropSize, cropSize),
      mean: cv.Scalar(mean[0] * 255, mean[1] * 255, mean[2] * 255),
      swapRB: true,
      crop: false,
    );
    cropped.release();

    // 5. Extrai buffer e monta tensor [1][3][299][299], dividindo por std
    final raw = blob.data.buffer.asFloat32List();
    final tensor = List.generate(
      1,
      (_) => List.generate(
        3,
        (_) => List.generate(cropSize, (_) => Float32List(cropSize)),
      ),
    );

    for (int c = 0; c < 3; c++) {
      int channelOffset = c * cropSize * cropSize;
      for (int y = 0; y < cropSize; y++) {
        for (int x = 0; x < cropSize; x++) {
          int idx = channelOffset + y * cropSize + x;
          tensor[0][c][y][x] = raw[idx] / std[c];
        }
      }
    }

    return tensor;
  }

  QualidadeImagem avaliarImagem(Map<int, List<List<double>>> resultadoModelo) {
    final vetor = resultadoModelo[0]?[0];

    if (vetor == null || vetor.length != 3) {
      throw Exception('Formato inválido do vetor na chave 2');
    }

    final indiceMaior = vetor.indexOf(vetor.reduce((a, b) => a > b ? a : b));

    switch (indiceMaior) {
      case 0:
        return QualidadeImagem.boa;
      case 1:
        return QualidadeImagem.usavel;
      case 2:
        return QualidadeImagem.rejeitada;
      default:
        throw Exception('Índice fora do esperado');
    }
  }

  Future<TipoImagem> runTypeImageClassifier(File imageFile) async {
    try {
      final image = img.decodeImage(await imageFile.readAsBytes());
      final resized = img.copyResize(image!, width: 224, height: 224);

      final input = Float32List(1 * 224 * 224 * 3);

      int index = 0;
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);
          input[index++] = pixel.r.toDouble();
          input[index++] = pixel.g.toDouble();
          input[index++] = pixel.b.toDouble();
        }
      }

      final output = List.filled(1 * 4, 0.0).reshape([1, 4]);

      typeImageClassifier.run(input.reshape([1, 224, 224, 3]), output);

      return interpretaClassificacaoTipoResult(output[0]);
    } catch (e) {
      debugPrint("Erro detalhado: ${e.toString()}");
      rethrow;
    }
  }

  TipoImagem interpretaClassificacaoTipoResult(List<double> output) {
    final classNames = [
      TipoImagem.olho,
      TipoImagem.retina,
      TipoImagem.retinaPB,
      TipoImagem.noEye,
    ];

    final maxIndex = output.indexOf(output.reduce((a, b) => a > b ? a : b));

    return classNames[maxIndex];
  }

  void printAllImages() {
    debugPrint("===========Valores===============");
    List elementos = hive.databaseBox.values.toList();
    for (ImageClassifyingResult imageClassifyingResult in elementos) {
      debugPrint("Caminho: ${imageClassifyingResult.caminhoImagem}");
      debugPrint("Paciente: ${imageClassifyingResult.paciente}");
      debugPrint(
        "Qualidade: ${imageClassifyingResult.qualidadeImagem.toString()}",
      );
      debugPrint("Tipo: ${imageClassifyingResult.tipoImagem.toString()}");
    }
  }

  Future<ImageClassifyingResult> avaliaImagemMelhorada(File entryImage) async {
    String imagePath = entryImage.path;
    if (hive.databaseBox.get(imagePath) != null) {
      throw Exception("imagem já foi classificada");
    }
    try {
      TipoImagem tipoImagem = await runTypeImageClassifier(entryImage);
      debugPrint(entryImage.path);
      ImageClassifyingResult imageClassifyingResult = ImageClassifyingResult(
        qualidadeImagem: null,
        tipoImagem: tipoImagem,
        paciente: path.dirname(imagePath).split('/').last,
        caminhoImagem: imagePath,
        dataClassificacao: DateTime.now(),
        caminhoImagemMelhorada: null,
        qualidadeImagemMelhorada: null,
      );
      if (tipoImagem == TipoImagem.retina) {
        var inputTensor1 = await imageToTensor(entryImage);

        var inputs = [inputTensor1];

        var outputs = {
          0: List.generate(1, (_) => List.filled(3, 0.0)),
          1: List.generate(1, (_) => List.filled(1280, 0.0)),
        };
        qualityImageClassifier.run(inputs, outputs);

        debugPrint(outputs.toString());
        QualidadeImagem qualidadeImagem = avaliarImagem(outputs);
        imageClassifyingResult.qualidadeImagem = qualidadeImagem;
      } else {
        imageClassifyingResult.qualidadeImagem = QualidadeImagem.rejeitada;
      }
      hive.databaseBox.put(imagePath, imageClassifyingResult);
      await hive.databaseBox.flush();
      return imageClassifyingResult;
    } catch (e) {
      PrintLogService.printLogInTxt(
        e.toString(),
        File(hive.databaseBox.path!).parent.path,
      );
      rethrow;
    }
  }
}

void printModelInfo(Interpreter interpreter) {
  final inputs = interpreter.getInputTensors();
  final outputs = interpreter.getOutputTensors();

  debugPrint("========== INPUT TENSORS ==========");

  for (var tensor in inputs) {
    debugPrint("Nome: ${tensor.name}");
    debugPrint("Shape: ${tensor.shape}");
    debugPrint("Tipo: ${tensor.type}");
    debugPrint("Quantization: ${tensor.params}");
    debugPrint("----------------------------");
  }

  debugPrint("========== OUTPUT TENSORS ==========");

  for (var tensor in outputs) {
    debugPrint("Nome: ${tensor.name}");
    debugPrint("Shape: ${tensor.shape}");
    debugPrint("Tipo: ${tensor.type}");
    debugPrint("Quantization: ${tensor.params}");
    debugPrint("----------------------------");
  }
}

@HiveType(typeId: 1)
enum QualidadeImagem {
  @HiveField(0)
  boa,
  @HiveField(1)
  usavel,
  @HiveField(2)
  rejeitada,
}

@HiveType(typeId: 2)
enum TipoImagem {
  @HiveField(0)
  olho,
  @HiveField(1)
  retina,
  @HiveField(2)
  retinaPB,
  @HiveField(3)
  noEye,
}

extension TipoImagemExt on TipoImagem {
  String get label {
    switch (this) {
      case TipoImagem.olho:
        return 'Olho';
      case TipoImagem.retina:
        return 'Retina';
      case TipoImagem.retinaPB:
        return 'Retina Red-free';
      case TipoImagem.noEye:
        return 'Sem estrutura avaliável';
    }
  }
}

extension QualidadeImagemExt on QualidadeImagem {
  String get label {
    switch (this) {
      case QualidadeImagem.boa:
        return 'Boa';
      case QualidadeImagem.usavel:
        return 'Usável';
      case QualidadeImagem.rejeitada:
        return 'Rejeitada';
    }
  }
}
