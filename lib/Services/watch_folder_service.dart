import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watcher/watcher.dart';

class FolderWatcherService {
  StreamSubscription? _subscription;
  late DirectoryWatcher _watcher;
  late void Function(WatchEvent) action;
  bool initialized = false;

  String folderPath = "/storage/emulated/0/DCIM/Camera";

  FolderWatcherService({required this.action, required this.folderPath}) {
    _initializeWatcher();
  }

  Future<void> initializeService() async {
    try {
      await _initializeWatcher();
      initialized = true;
    } catch (e) {
      initialized = false;
    }
  }

  Future<void> _initializeWatcher() async {
    try {
      _subscription?.cancel();
      _watcher = DirectoryWatcher(folderPath);
      await _startListening();
      debugPrint("Observando pasta: $folderPath");
    } catch (e) {
      debugPrint("Erro ao inicializar watcher para $folderPath: $e");
      rethrow;
    }
  }

  Future<void> updateWatcherFolder(String newPath) async {
    if (initialized) {
      folderPath = newPath;
      await _initializeWatcher();
    }
  }

  Future<void> _startListening() async {
    _subscription = _watcher.events.listen((event) {
      if(event.type.toString() == 'add' || event.type.toString() == 'modify'){
        action(event);
      }
    });
  }

  void updateAction(void Function(WatchEvent) newAction) {
    action = newAction;
    _watcher.events.listen(action);
  }

  void pause() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint("Serviço pausado");
  }

  void resume() {
    if (_subscription == null) {
      _startListening();
      debugPrint("Serviço retomado");
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
