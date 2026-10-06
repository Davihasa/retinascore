import 'dart:convert';

enum EventType { initWatcher, updateWatcherPath, isActivated, overlayReady}

class OverlayEvent {
  final EventType eventType;
  final String? watcherPath;
  final bool? isActivated;

  OverlayEvent({required this.eventType, this.watcherPath, this.isActivated});

  Map<String, dynamic> toJson() => {
    'eventType': eventType.index,
    'watcherPath': watcherPath,
    'isActivated': isActivated,
  };

  factory OverlayEvent.fromJson(Map<String, dynamic> json) => OverlayEvent(
    eventType: EventType.values[json['eventType']],
    watcherPath: json['watcherPath'],
    isActivated: json['isActivated'],
  );

  String toJsonString() => jsonEncode(toJson());

  factory OverlayEvent.fromJsonString(String jsonString) =>
      OverlayEvent.fromJson(jsonDecode(jsonString));
}
