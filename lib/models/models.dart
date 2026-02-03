import 'package:uuid/uuid.dart';

class CoffeeMachine {
  final String id;
  final String name;
  final double? defaultPressure;
  final double? defaultTemperature;
  final int? defaultPreInfusionTime;

  CoffeeMachine({
    String? id,
    required this.name,
    this.defaultPressure,
    this.defaultTemperature,
    this.defaultPreInfusionTime,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'defaultPressure': defaultPressure,
      'defaultTemperature': defaultTemperature,
      'defaultPreInfusionTime': defaultPreInfusionTime,
    };
  }

  factory CoffeeMachine.fromJson(Map<String, dynamic> json) {
    return CoffeeMachine(
      id: json['id'],
      name: json['name'],
      defaultPressure: json['defaultPressure']?.toDouble(),
      defaultTemperature: json['defaultTemperature']?.toDouble(),
      defaultPreInfusionTime: json['defaultPreInfusionTime'],
    );
  }
}

class Grinder {
  final String id;
  final String name;
  final double? defaultRpm;

  Grinder({String? id, required this.name, this.defaultRpm})
    : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'defaultRpm': defaultRpm};
  }

  factory Grinder.fromJson(Map<String, dynamic> json) {
    return Grinder(
      id: json['id'],
      name: json['name'],
      defaultRpm: json['defaultRpm']?.toDouble(),
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
  final String? water;
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
    this.water,
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
      'water': water,
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
      grinderRpm: json['grinderRpm']?.toDouble(),
      pressure: json['pressure']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
      preInfusionTime: json['preInfusionTime'],
      machineId: json['machineId'],
      grinderId: json['grinderId'],
      water: json['water'],
      flavourX: json['flavourX']?.toDouble(),
      flavourY: json['flavourY']?.toDouble(),
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

  // Flavor Profile (0.0 - 10.0)
  final double acidity;
  final double body;
  final double sweetness;
  final double bitterness;
  final double aftertaste;
  
  // Custom Flavor Attributes (name -> value)
  final Map<String, double> customFlavorValues;

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
    this.acidity = 5.0,
    this.body = 5.0,
    this.sweetness = 5.0,
    this.bitterness = 5.0,
    this.aftertaste = 5.0,
    Map<String, double>? customFlavorValues,
  }) : id = id ?? const Uuid().v4(),
       shots = shots ?? [],
       customFlavorValues = customFlavorValues ?? {};

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
      'acidity': acidity,
      'body': body,
      'sweetness': sweetness,
      'bitterness': bitterness,
      'aftertaste': aftertaste,
      'customFlavorValues': customFlavorValues,
    };
  }

  factory Bean.fromJson(Map<String, dynamic> json) {
    return Bean(
      id: json['id'],
      name: json['name'],
      notes: json['notes'] ?? '',
      preferredGrindSize: json['preferredGrindSize']?.toDouble() ?? 10.0,
      shots:
          (json['shots'] as List?)?.map((s) => Shot.fromJson(s)).toList() ?? [],
      origin: json['origin'] ?? '',
      roastLevel: json['roastLevel'] ?? 'Medium',
      process: json['process'] ?? '',
      flavourTags:
          (json['flavourTags'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      roastDate: json['roastDate'] != null
          ? DateTime.parse(json['roastDate'])
          : null,
      acidity: json['acidity']?.toDouble() ?? 5.0,
      body: json['body']?.toDouble() ?? 5.0,
      sweetness: json['sweetness']?.toDouble() ?? 5.0,
      bitterness: json['bitterness']?.toDouble() ?? 5.0,
      aftertaste: json['aftertaste']?.toDouble() ?? 5.0,
      customFlavorValues: (json['customFlavorValues'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, (value as num).toDouble())) ?? {},
    );
  }
}
