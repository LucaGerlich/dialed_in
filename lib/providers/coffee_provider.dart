import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class CoffeeProvider with ChangeNotifier {
  List<Bean> _beans = [];
  List<CoffeeMachine> _machines = [];
  List<Grinder> _grinders = [];
  
  // Grind Settings
  double _grindMin = 0.0;
  double _grindMax = 30.0;
  double _grindStep = 0.5;

  // Theme Settings
  ThemeMode _themeMode = ThemeMode.system;

  List<Bean> get beans => _beans;
  List<CoffeeMachine> get machines => _machines;
  List<Grinder> get grinders => _grinders;
  
  double get grindMin => _grindMin;
  double get grindMax => _grindMax;
  double get grindStep => _grindStep;
  ThemeMode get themeMode => _themeMode;

  CoffeeProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? beansJson = prefs.getString('beans');
    if (beansJson != null) {
      final List<dynamic> decoded = jsonDecode(beansJson);
      _beans = decoded.map((item) => Bean.fromJson(item)).toList();
    }

    final String? machinesJson = prefs.getString('machines');
    if (machinesJson != null) {
      final List<dynamic> decoded = jsonDecode(machinesJson);
      _machines = decoded.map((item) => CoffeeMachine.fromJson(item)).toList();
    }

    final String? grindersJson = prefs.getString('grinders');
    if (grindersJson != null) {
      final List<dynamic> decoded = jsonDecode(grindersJson);
      _grinders = decoded.map((item) => Grinder.fromJson(item)).toList();
    }
    
    _grindMin = prefs.getDouble('grindMin') ?? 0.0;
    _grindMax = prefs.getDouble('grindMax') ?? 30.0;
    _grindStep = prefs.getDouble('grindStep') ?? 0.5;
    
    final String? themeModeStr = prefs.getString('themeMode');
    if (themeModeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeStr,
        orElse: () => ThemeMode.system,
      );
    }
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String beansJson = jsonEncode(_beans.map((b) => b.toJson()).toList());
    await prefs.setString('beans', beansJson);
    
    final String machinesJson = jsonEncode(_machines.map((m) => m.toJson()).toList());
    await prefs.setString('machines', machinesJson);

    final String grindersJson = jsonEncode(_grinders.map((g) => g.toJson()).toList());
    await prefs.setString('grinders', grindersJson);
    
    await prefs.setDouble('grindMin', _grindMin);
    await prefs.setDouble('grindMax', _grindMax);
    await prefs.setDouble('grindStep', _grindStep);
    await prefs.setString('themeMode', _themeMode.toString());
  }
  
  void updateGrindSettings(double min, double max, double step) {
    _grindMin = min;
    _grindMax = max;
    _grindStep = step;
    _saveData();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveData();
    notifyListeners();
  }

  void addBean(Bean bean) {
    _beans.add(bean);
    _saveData();
    notifyListeners();
  }

  void deleteBean(String id) {
    _beans.removeWhere((b) => b.id == id);
    _saveData();
    notifyListeners();
  }

  void updateBean(Bean updatedBean) {
    final index = _beans.indexWhere((b) => b.id == updatedBean.id);
    if (index != -1) {
      _beans[index] = updatedBean;
      _saveData();
      notifyListeners();
    }
  }

  void addShot(String beanId, Shot shot, {bool updatePreferredGrind = false}) {
    final beanIndex = _beans.indexWhere((b) => b.id == beanId);
    if (beanIndex != -1) {
      final bean = _beans[beanIndex];
      final updatedShots = List<Shot>.from(bean.shots)..add(shot);
      
      // Sort shots by timestamp descending (newest first)
      updatedShots.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Calculate new preferred grind if requested
      double newPreferred = bean.preferredGrindSize;
      if (updatePreferredGrind) {
        newPreferred = shot.grindSize;
      }

      _beans[beanIndex] = Bean(
        id: bean.id,
        name: bean.name,
        notes: bean.notes,
        preferredGrindSize: newPreferred,
        shots: updatedShots,
        origin: bean.origin,
        roastLevel: bean.roastLevel,
        process: bean.process,
        flavourTags: bean.flavourTags,
        roastDate: bean.roastDate,
        acidity: bean.acidity,
        body: bean.body,
        sweetness: bean.sweetness,
        bitterness: bean.bitterness,
        aftertaste: bean.aftertaste,
      );
      
      _saveData();
      notifyListeners();
    }
  }

  void addMachine(CoffeeMachine machine) {
    _machines.add(machine);
    _saveData();
    notifyListeners();
  }

  void deleteMachine(String id) {
    _machines.removeWhere((m) => m.id == id);
    _saveData();
    notifyListeners();
  }

  void addGrinder(Grinder grinder) {
    _grinders.add(grinder);
    _saveData();
    notifyListeners();
  }

  void deleteGrinder(String id) {
    _grinders.removeWhere((g) => g.id == id);
    _saveData();
    notifyListeners();
  }

  /// Returns all data as a JSON string for export
  String exportDataToJson() {
    final exportData = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'beans': _beans.map((b) => b.toJson()).toList(),
      'machines': _machines.map((m) => m.toJson()).toList(),
      'grinders': _grinders.map((g) => g.toJson()).toList(),
      'settings': {
        'grindMin': _grindMin,
        'grindMax': _grindMax,
        'grindStep': _grindStep,
        'themeMode': _themeMode.toString(),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Exports data to a JSON file and returns the file path
  Future<String> exportDataToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File('${directory.path}/dialed_in_export_$timestamp.json');
    await file.writeAsString(exportDataToJson());
    return file.path;
  }

  /// Imports data from a JSON string, merging with or replacing existing data
  Future<void> importDataFromJson(String jsonString, {bool replaceExisting = true}) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    
    // Import beans
    if (data['beans'] != null) {
      final List<dynamic> beansJson = data['beans'];
      final importedBeans = beansJson.map((item) => Bean.fromJson(item)).toList();
      if (replaceExisting) {
        _beans = importedBeans;
      } else {
        // Merge: add beans that don't already exist by ID
        final existingIds = _beans.map((b) => b.id).toSet();
        for (final bean in importedBeans) {
          if (!existingIds.contains(bean.id)) {
            _beans.add(bean);
          }
        }
      }
    }

    // Import machines
    if (data['machines'] != null) {
      final List<dynamic> machinesJson = data['machines'];
      final importedMachines = machinesJson.map((item) => CoffeeMachine.fromJson(item)).toList();
      if (replaceExisting) {
        _machines = importedMachines;
      } else {
        final existingIds = _machines.map((m) => m.id).toSet();
        for (final machine in importedMachines) {
          if (!existingIds.contains(machine.id)) {
            _machines.add(machine);
          }
        }
      }
    }

    // Import grinders
    if (data['grinders'] != null) {
      final List<dynamic> grindersJson = data['grinders'];
      final importedGrinders = grindersJson.map((item) => Grinder.fromJson(item)).toList();
      if (replaceExisting) {
        _grinders = importedGrinders;
      } else {
        final existingIds = _grinders.map((g) => g.id).toSet();
        for (final grinder in importedGrinders) {
          if (!existingIds.contains(grinder.id)) {
            _grinders.add(grinder);
          }
        }
      }
    }

    // Import settings (only if replacing or if they exist in the import)
    if (data['settings'] != null && replaceExisting) {
      final settings = data['settings'];
      _grindMin = settings['grindMin']?.toDouble() ?? _grindMin;
      _grindMax = settings['grindMax']?.toDouble() ?? _grindMax;
      _grindStep = settings['grindStep']?.toDouble() ?? _grindStep;
      if (settings['themeMode'] != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.toString() == settings['themeMode'],
          orElse: () => _themeMode,
        );
      }
    }

    await _saveData();
    notifyListeners();
  }
}
