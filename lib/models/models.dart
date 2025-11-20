import 'package:uuid/uuid.dart';

class CoffeeMachine {
  final String id;
  final String name;

  CoffeeMachine({
    String? id,
    required this.name,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory CoffeeMachine.fromJson(Map<String, dynamic> json) {
    return CoffeeMachine(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Grinder {
  final String id;
  final String name;

  Grinder({
    String? id,
    required this.name,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Grinder.fromJson(Map<String, dynamic> json) {
    return Grinder(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Shot {
  final String id;
  final double grindSize;
  final double doseIn; // grams
  final double doseOut; // grams
  final int duration; // seconds
  final DateTime timestamp;

  // New Fields
  final double? grinderRpm;
  final double? pressure;
  final double? temperature;
  final int? preInfusionTime;
  final String? machineId;
  final String? grinderId;
  final double? flavourX; // -1 (Sour) to 1 (Bitter)
  final double? flavourY; // -1 (Weak) to 1 (Strong)

  Shot({
    String? id,
    required this.grindSize,
    required this.doseIn,
    required this.doseOut,
    required this.duration,
    required this.timestamp,
    this.grinderRpm,
    this.pressure,
    this.temperature,
    this.preInfusionTime,
    this.machineId,
    this.grinderId,
    this.flavourX,
    this.flavourY,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grindSize': grindSize,
      'doseIn': doseIn,
      'doseOut': doseOut,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'grinderRpm': grinderRpm,
      'pressure': pressure,
      'temperature': temperature,
      'preInfusionTime': preInfusionTime,
      'machineId': machineId,
      'grinderId': grinderId,
      'flavourX': flavourX,
      'flavourY': flavourY,
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
  final String name;
  final String notes;
  final double preferredGrindSize;
  final List<Shot> shots;
  
  // New Fields
  final String origin;
  final String roastLevel; // Light, Medium, Dark
  final String process; // Washed, Natural, Honey, etc.
  final List<String> flavourTags;
  final DateTime? roastDate;

  Bean({
    String? id,
    required this.name,
    this.notes = '',
    this.preferredGrindSize = 10.0,
    List<Shot>? shots,
    this.origin = '',
    this.roastLevel = 'Medium',
    this.process = '',
    this.flavourTags = const [],
    this.roastDate,
  })  : id = id ?? const Uuid().v4(),
        shots = shots ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'preferredGrindSize': preferredGrindSize,
      'shots': shots.map((s) => s.toJson()).toList(),
      'origin': origin,
      'roastLevel': roastLevel,
      'process': process,
      'flavourTags': flavourTags,
      'roastDate': roastDate?.toIso8601String(),
    };
  }

  factory Bean.fromJson(Map<String, dynamic> json) {
    return Bean(
      id: json['id'],
      name: json['name'],
      notes: json['notes'] ?? '',
      preferredGrindSize: json['preferredGrindSize']?.toDouble() ?? 10.0,
      shots: (json['shots'] as List?)
              ?.map((s) => Shot.fromJson(s))
              .toList() ??
          [],
      origin: json['origin'] ?? '',
      roastLevel: json['roastLevel'] ?? 'Medium',
      process: json['process'] ?? '',
      flavourTags: (json['flavourTags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      roastDate: json['roastDate'] != null ? DateTime.parse(json['roastDate']) : null,
    );
  }
}
