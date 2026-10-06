import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Models/overlay_event.dart';
import 'package:retinoscore/Services/database_box.dart';
import 'package:retinoscore/Services/image_classifier_service.dart';
import 'package:retinoscore/Services/image_enhancement_service.dart';
import 'package:retinoscore/Services/watch_folder_service.dart';
import 'package:retinoscore/Widgets/good_pop_up.dart';
import 'package:retinoscore/Widgets/loading_inference_pop_up.dart';
import 'package:retinoscore/Widgets/rejected_pop_up.dart';
import 'package:retinoscore/Widgets/usable_pop_up.dart';
import 'package:retinoscore/Widgets/waiting_for_image_popup.dart';
import 'package:path/path.dart' as p;

enum OverlayVisualState { compact, expanded }

class PopUpOverlay extends StatefulWidget {
  const PopUpOverlay({super.key});

  @override
  State<PopUpOverlay> createState() => _PopUpOverlayState();
}

class _PopUpOverlayState extends State<PopUpOverlay>
    with WidgetsBindingObserver {
  late ClassifierModel classifierModel;
  bool loading = false;
  QualidadeImagem? result;
  bool _modelInitialized = false;
  FolderWatcherService? watcherService;
  late DatabaseBox databaseBox;
  bool isProcessing = false;
  bool _overlayIsReady = false;
  bool showedMessageOnce = false;
  OverlayVisualState estadoAtual = OverlayVisualState.compact;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    FlutterOverlayWindow.overlayListener.listen((data) async {
      try {
        final event = OverlayEvent.fromJsonString(data.toString());
        if (event.eventType == EventType.initWatcher) {
          await _initializeModel();
          watcherService = FolderWatcherService(
            action: (event) {
              handleNewImage(event.path);
            },
            folderPath: event.watcherPath!,
          );
          watcherService?.initializeService();

          databaseBox = DatabaseBox();
          await databaseBox.init();
        } else if (event.eventType == EventType.updateWatcherPath) {
          try {
            watcherService?.updateWatcherFolder(event.watcherPath!);
          } on Exception {
            watcherService = FolderWatcherService(
              action: (event) {
                handleNewImage(event.path);
              },
              folderPath: event.watcherPath!,
            );
            watcherService?.initializeService();
            databaseBox = DatabaseBox();
            await databaseBox.init();
          }
        } else if (event.eventType == EventType.isActivated) {
          if (!event.isActivated! && await FlutterOverlayWindow.isActive()) {
            FlutterOverlayWindow.closeOverlay();
          }
        } else if (event.eventType == EventType.overlayReady) {
          setState(() {
            _overlayIsReady = true;
          });
        }
      } catch (e) {
        debugPrint("Erro ao processar evento: $e");
      }
    });
  }

  Future<void> resizeOverlay(OverlayVisualState state) async {
    if (estadoAtual == state) return;
    if (state == OverlayVisualState.compact) {
      try {
        await FlutterOverlayWindow.resizeOverlay(61, 61, true);
        // await FlutterOverlayWindow.moveOverlay(overlayPosition);
        estadoAtual = OverlayVisualState.compact;
        debugPrint("Overlay redimensionado para 61x61.");
      } catch (e) {
        debugPrint("Erro ao fazer resizing do overlay: $e");
      }
    } else if (state == OverlayVisualState.expanded) {
      try {
        await FlutterOverlayWindow.resizeOverlay(308, 60, true);
        // await FlutterOverlayWindow.moveOverlay(overlayPosition);
        estadoAtual = OverlayVisualState.expanded;
        debugPrint("Overlay redimensionado para 308x60.");
      } catch (e) {
        debugPrint("Erro ao fazer resizing do overlay: $e");
      }
    }
  }

  Future<void> _initializeModel() async {
    if (_modelInitialized) return;
    classifierModel = ClassifierModel();
    await classifierModel.init();
    _modelInitialized = true;
    debugPrint("Modelo inicializado com sucesso no overlay.");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_modelInitialized) {
      debugPrint(
        "Overlay ativo, mas modelo ainda não inicializado — aguardando evento initWatcher",
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> handleNewImage(String path) async {
    if (!_modelInitialized || isProcessing) return;
    isProcessing = true;

    setState(() {
      loading = true;
      result = null; // limpa o resultado anterior
    });

    //trata organização de pastas do eyer:
    final fileSystemEntity = FileSystemEntity.typeSync(path);

    if (fileSystemEntity == FileSystemEntityType.directory) {
      final dir = Directory(path);
      final entities = await dir.list().toList();

      final files = entities.whereType<File>().toList();
      if (files.isEmpty) return;

      // Ordena do mais antigo pro mais recente
      files.sort((a, b) {
        final aModified = a.lastModifiedSync();
        final bModified = b.lastModifiedSync();
        return aModified.compareTo(bModified);
      });

      path = files.first.path;
    } else if (fileSystemEntity == FileSystemEntityType.file) {
      // path já é de um arquivo, não faz nada
    } else {
      // nem arquivo, nem pasta, ignora
      return;
    }
    try {
      debugPrint("imagem detectada: $path");

      final imageQualityResult = await classifierModel.classifyImageAndSave(
        File(path),
      );

      setState(() {
        result = imageQualityResult.qualidadeImagem;
        loading = false;
      });
      if (result == QualidadeImagem.usavel ||
          result == QualidadeImagem.rejeitada &&
              imageQualityResult.tipoImagem != TipoImagem.noEye) {
        runEnhancementModel(imageQualityResult);
      }

      // remove o resultado após 3 segundos
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        result = null;
      });
    } catch (e) {
      debugPrint("Erro na inferência: $e");
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } finally {
      isProcessing = false;
    }
  }

  Widget showPopupResult(QualidadeImagem? resultado) {
    if (loading) {
      return LoadingInferencePopUp();
    } else if (resultado == null) {
      return WaitingForImagePopup(
        resizeOverlay: resizeOverlay,
        overlayReady: _overlayIsReady,
        showedMessageOnce: showedMessageOnce,
        onMessageShown: () {
          showedMessageOnce = true;
        },
      );
    } else if (resultado == QualidadeImagem.boa) {
      return GoodPopUp(
        resizeOverlay: resizeOverlay,
        overlayReady: _overlayIsReady,
      );
    } else if (resultado == QualidadeImagem.usavel) {
      return UsablePopUp(
        resizeOverlay: resizeOverlay,
        overlayReady: _overlayIsReady,
      );
    } else if (resultado == QualidadeImagem.rejeitada) {
      return RejectedPopUp(
        resizeOverlay: resizeOverlay,
        overlayReady: _overlayIsReady,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return showPopupResult(result);
  }

  Future<void> runEnhancementModel(ImageClassifyingResult dadosImagem) async {
    try {
      // Executa o CLAHE em outro isolate, retornando o caminho do arquivo melhorado
      final caminhoImagemMelhorada = await compute(
        _enhanceImageInIsolate,
        dadosImagem.caminhoImagem,
      );

      // Depois que a imagem for melhorada, reclassifica e salva no Hive
      await classifierModel.reclassifyImageAndSave(
        dadosImagem.caminhoImagem,
        caminhoImagemMelhorada,
      );
    } catch (e) {
      debugPrint('Erro ao rodar modelo de melhoria: $e');
    }
  }
}

Future<String> _enhanceImageInIsolate(String caminhoImagem) async {
  final arquivo = File(caminhoImagem);
  final diretorio = arquivo.parent;

  // Aplica CLAHE
  final imagemMelhorada = await EnhancementService.applyClahe(arquivo);

  // Salva a imagem melhorada no mesmo diretório
  final caminhoImagemMelhorada =
      '${diretorio.path}/${p.basenameWithoutExtension(arquivo.path)}_melhorada.png';
  await File(caminhoImagemMelhorada).writeAsBytes(imagemMelhorada);

  // Retorna apenas o caminho
  return caminhoImagemMelhorada;
}
