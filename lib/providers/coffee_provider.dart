import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class CoffeeProvider with ChangeNotifier {
  List<Bean> _beans = [];

  List<Bean> get beans => _beans;

  CoffeeProvider() {
    _loadBeans();
  }

  Future<void> _loadBeans() async {
    final prefs = await SharedPreferences.getInstance();
    final String? beansJson = prefs.getString('beans');
    if (beansJson != null) {
      final List<dynamic> decodedList = jsonDecode(beansJson);
      _beans = decodedList.map((item) => Bean.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveBeans() async {
    final prefs = await SharedPreferences.getInstance();
    final String beansJson = jsonEncode(_beans.map((b) => b.toJson()).toList());
    await prefs.setString('beans', beansJson);
    notifyListeners();
  }

  void addBean(Bean bean) {
    _beans.add(bean);
    _saveBeans();
  }

  void deleteBean(String id) {
    _beans.removeWhere((b) => b.id == id);
    _saveBeans();
  }

  void updateBean(Bean updatedBean) {
    final index = _beans.indexWhere((b) => b.id == updatedBean.id);
    if (index != -1) {
      _beans[index] = updatedBean;
      _saveBeans();
    }
  }

  void addShot(String beanId, Shot shot, {bool updatePreferredGrind = false}) {
    final beanIndex = _beans.indexWhere((b) => b.id == beanId);
    if (beanIndex != -1) {
      _beans[beanIndex].shots.add(shot);
      // Sort shots by timestamp descending (newest first)
      _beans[beanIndex].shots.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      if (updatePreferredGrind) {
        _beans[beanIndex].preferredGrindSize = shot.grindSize;
      }
      
      _saveBeans();
    }
  }
}
