import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  List<Bean> get beans => _beans;
  List<CoffeeMachine> get machines => _machines;
  List<Grinder> get grinders => _grinders;
  
  double get grindMin => _grindMin;
  double get grindMax => _grindMax;
  double get grindStep => _grindStep;

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
  }
  
  void updateGrindSettings(double min, double max, double step) {
    _grindMin = min;
    _grindMax = max;
    _grindStep = step;
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
}
