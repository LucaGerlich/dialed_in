import 'package:uuid/uuid.dart';

class Shot {
  final String id;
  final double grindSize;
  final double doseIn; // grams
  final double doseOut; // grams
  final int duration; // seconds
  final DateTime timestamp;

  Shot({
    String? id,
    required this.grindSize,
    required this.doseIn,
    required this.doseOut,
    required this.duration,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grindSize': grindSize,
      'doseIn': doseIn,
      'doseOut': doseOut,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Shot.fromJson(Map<String, dynamic> json) {
    return Shot(
      id: json['id'],
      grindSize: json['grindSize'].toDouble(),
      doseIn: json['doseIn'].toDouble(),
      doseOut: json['doseOut'].toDouble(),
      duration: json['duration'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Bean {
  final String id;
  String name;
  String notes;
  double? preferredGrindSize;
  List<Shot> shots;

  Bean({
    String? id,
    required this.name,
    this.notes = '',
    this.preferredGrindSize,
    List<Shot>? shots,
  })  : id = id ?? const Uuid().v4(),
        shots = shots ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'preferredGrindSize': preferredGrindSize,
      'shots': shots.map((s) => s.toJson()).toList(),
    };
  }

  factory Bean.fromJson(Map<String, dynamic> json) {
    return Bean(
      id: json['id'],
      name: json['name'],
      notes: json['notes'] ?? '',
      preferredGrindSize: json['preferredGrindSize']?.toDouble(),
      shots: (json['shots'] as List?)
              ?.map((s) => Shot.fromJson(s))
              .toList() ??
          [],
    );
  }
}
