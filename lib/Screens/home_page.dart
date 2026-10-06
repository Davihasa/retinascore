import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Screens/historic_page_by_pacient.dart';
import 'package:retinoscore/Services/activation_state_manager.dart';
import 'package:retinoscore/Services/database_box.dart';
import 'package:retinoscore/Styles/colors.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:retinoscore/Models/overlay_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  void _toggleActivation() {
    context.read<ActivationState>().toggle();
    FlutterOverlayWindow.shareData(
      OverlayEvent(
        eventType: EventType.isActivated,
        isActivated: context.read<ActivationState>().activated,
      ).toJsonString(),
    );
  }

  late String watcherPath;

  DatabaseBox hive = DatabaseBox();
  late List<ImageClassifyingResult> imagensClassificadas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    watcherPath = "/storage/emulated/0/DCIM/Camera";
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initHiveDatabase();
      await syncPopUpState();
      await notifyOverlayAbtInit();
    });
  }

  Future<void> initHiveDatabase() async {
    await hive.init();
    if (hive.pathToWatch.isEmpty) {
      await hive.pathToWatch.add(watcherPath);
    } else {
      setState(() {
        watcherPath = hive.pathToWatch.getAt(0)!;
      });
      await FlutterOverlayWindow.shareData(
        OverlayEvent(
          eventType: EventType.updateWatcherPath,
          watcherPath: watcherPath,
        ).toJsonString(),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused &&
        context.read<ActivationState>().activated) {
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
        await Future.delayed(const Duration(milliseconds: 300));
      }
      await FlutterOverlayWindow.showOverlay(
        height: 160,
        width: 160,
        alignment: OverlayAlignment.centerRight,
        flag: OverlayFlag.defaultFlag,
        enableDrag: true,
        positionGravity: PositionGravity.auto,
      );
      await FlutterOverlayWindow.shareData(
        OverlayEvent(eventType: EventType.overlayReady).toJsonString(),
      );
    }
    if (state == AppLifecycleState.resumed) {
      FlutterOverlayWindow.closeOverlay();
    }
  }

  Future<void> pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Selecione um diretório',
      initialDirectory: '/storage/emulated/0/',
    );

    if (selectedDirectory != null) {
      debugPrint("Diretório selecionado: $selectedDirectory");
      await hive.pathToWatch.clear();
      await hive.pathToWatch.add(selectedDirectory);
      setState(() {
        watcherPath = selectedDirectory;
      });
      await FlutterOverlayWindow.shareData(
        OverlayEvent(
          eventType: EventType.updateWatcherPath,
          watcherPath: watcherPath,
        ).toJsonString(),
      );
    } else {
      debugPrint("Nenhum diretório foi selecionado");
    }
  }

  Future<void> notifyOverlayAbtInit() async {
    await Future.delayed(Duration(milliseconds: 500));
    await FlutterOverlayWindow.shareData(
      OverlayEvent(
        eventType: EventType.initWatcher,
        watcherPath: watcherPath,
      ).toJsonString(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final activated = context.watch<ActivationState>().activated;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        elevation: 3,
                        shape: const CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: 55,
                          child: IconButton(
                            icon: Icon(
                              activated
                                  ? Icons.image_search_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 70,
                            ),
                            onPressed: _toggleActivation,
                          ),
                        ),
                      ),
                      const SizedBox(height: 140),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Aguardando por imagens em: $watcherPath",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton(
                        onPressed: activated ? null : pickDirectory,
                        child: Text("Alterar caminho"),
                      ),
                      SizedBox(height: 122),
                      ElevatedButton(
                        onPressed: _toggleActivation,
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(250, 50),
                        ),
                        child: Text(
                          activated ? "Pausar" : "Iniciar",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HistoricPageByPacient();
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(250, 50),
                        ),
                        child: Text(
                          "Abrir histórico",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> fetchImagensClassificadas() async {
    await hive.databaseBox.close();
    hive.databaseBox = await Hive.openBox<ImageClassifyingResult>('resultsBox');

    final futures = hive.databaseBox.values.map((result) async {
      try {
        final file = File(result.caminhoImagem);
        return await file.exists() ? result : null;
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
  }

  Future<void> syncPopUpState() async {
    if (mounted) {
      if (await FlutterOverlayWindow.isActive()) {
        setState(() {
          context.read<ActivationState>().setActivated(true);
        });
        FlutterOverlayWindow.closeOverlay();
      } else {
        setState(() {
          context.read<ActivationState>().setActivated(false);
        });
      }
    }
  }
}
