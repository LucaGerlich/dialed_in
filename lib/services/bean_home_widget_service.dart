import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/models.dart';

class BeanHomeWidgetService {
  static const String _androidWidgetProvider = 'BeanStatsWidgetProvider';

  static Future<void> sync(List<Bean> beans) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final totalShots = beans.fold<int>(
      0,
      (sum, bean) => sum + bean.shots.length,
    );
    final topBean = _pickTopBean(beans);

    await HomeWidget.saveWidgetData<int>('bean_count', beans.length);
    await HomeWidget.saveWidgetData<int>('total_shots', totalShots);
    await HomeWidget.saveWidgetData<String>(
      'top_bean',
      topBean?.name ?? 'No beans yet',
    );
    await HomeWidget.saveWidgetData<String>(
      'widget_last_sync',
      DateTime.now().toIso8601String(),
    );

    await HomeWidget.updateWidget(androidName: _androidWidgetProvider);
  }

  static Bean? _pickTopBean(List<Bean> beans) {
    if (beans.isEmpty) return null;

    final sorted = List<Bean>.from(beans)
      ..sort((a, b) {
        final rankingComparison = b.ranking.compareTo(a.ranking);
        if (rankingComparison != 0) return rankingComparison;

        final shotComparison = b.shots.length.compareTo(a.shots.length);
        if (shotComparison != 0) return shotComparison;

        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return sorted.first;
  }
}
