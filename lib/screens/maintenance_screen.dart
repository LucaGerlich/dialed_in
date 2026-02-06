import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coffee_provider.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<CoffeeProvider>(
        builder: (context, provider, child) {
          final tasks = provider.maintenanceTasks;

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No maintenance tasks',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a task to get started',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _MaintenanceTaskCard(task: task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddMaintenanceTaskDialog(),
    );
  }
}

class _MaintenanceTaskCard extends StatelessWidget {
  final MaintenanceTask task;

  const _MaintenanceTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoffeeProvider>(context, listen: false);

    // Calculate progress
    final progress = _calculateProgress(provider);
    final isOverdue = progress >= 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTaskDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIconForType(task.type),
                    color: isOverdue
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name,
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getIntervalDescription(),
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverdue
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getProgressDescription(provider),
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (task.lastCompleted != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Last: ${DateFormat('MMM d, yyyy').format(task.lastCompleted!)}',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _calculateProgress(CoffeeProvider provider) {
    if (task.lastCompleted == null) {
      // If never completed, calculate based on total usage
      switch (task.intervalType) {
        case MaintenanceIntervalType.shots:
          final totalShots = provider.getTotalShotCount();
          return totalShots / task.intervalValue;
        case MaintenanceIntervalType.days:
          // Can't calculate without a start date, assume 0
          return 0.0;
        case MaintenanceIntervalType.waterLiters:
          final totalWater = provider.getTotalWaterUsage();
          return totalWater / task.intervalValue;
      }
    }

    switch (task.intervalType) {
      case MaintenanceIntervalType.shots:
        // Count shots since last completion
        int shotsSince = 0;
        for (final bean in provider.beans) {
          for (final shot in bean.shots) {
            if (shot.timestamp.isAfter(task.lastCompleted!)) {
              shotsSince++;
            }
          }
        }
        return shotsSince / task.intervalValue;

      case MaintenanceIntervalType.days:
        final daysSince = DateTime.now().difference(task.lastCompleted!).inDays;
        return daysSince / task.intervalValue;

      case MaintenanceIntervalType.waterLiters:
        // Count shots since last completion and calculate water
        int shotsSince = 0;
        for (final bean in provider.beans) {
          for (final shot in bean.shots) {
            if (shot.timestamp.isAfter(task.lastCompleted!)) {
              shotsSince++;
            }
          }
        }
        final waterSince = shotsSince * 0.06; // 60ml per shot
        return waterSince / task.intervalValue;
    }
  }

  String _getProgressDescription(CoffeeProvider provider) {
    if (task.lastCompleted == null) {
      switch (task.intervalType) {
        case MaintenanceIntervalType.shots:
          final totalShots = provider.getTotalShotCount();
          return '$totalShots / ${task.intervalValue} shots';
        case MaintenanceIntervalType.days:
          return 'Never completed';
        case MaintenanceIntervalType.waterLiters:
          final totalWater = provider.getTotalWaterUsage();
          return '${totalWater.toStringAsFixed(1)} / ${task.intervalValue} L';
      }
    }

    switch (task.intervalType) {
      case MaintenanceIntervalType.shots:
        int shotsSince = 0;
        for (final bean in provider.beans) {
          for (final shot in bean.shots) {
            if (shot.timestamp.isAfter(task.lastCompleted!)) {
              shotsSince++;
            }
          }
        }
        return '$shotsSince / ${task.intervalValue} shots';

      case MaintenanceIntervalType.days:
        final daysSince = DateTime.now().difference(task.lastCompleted!).inDays;
        return '$daysSince / ${task.intervalValue} days';

      case MaintenanceIntervalType.waterLiters:
        int shotsSince = 0;
        for (final bean in provider.beans) {
          for (final shot in bean.shots) {
            if (shot.timestamp.isAfter(task.lastCompleted!)) {
              shotsSince++;
            }
          }
        }
        final waterSince = shotsSince * 0.06;
        return '${waterSince.toStringAsFixed(1)} / ${task.intervalValue} L';
    }
  }

  String _getIntervalDescription() {
    switch (task.intervalType) {
      case MaintenanceIntervalType.shots:
        return 'Every ${task.intervalValue} shots';
      case MaintenanceIntervalType.days:
        return 'Every ${task.intervalValue} days';
      case MaintenanceIntervalType.waterLiters:
        return 'Every ${task.intervalValue} liters';
    }
  }

  IconData _getIconForType(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.clean:
        return Icons.cleaning_services;
      case MaintenanceType.decalcify:
        return Icons.water_drop;
      case MaintenanceType.checkMachine:
        return Icons.coffee_maker;
      case MaintenanceType.checkGrinder:
        return Icons.settings;
    }
  }

  void _showTaskDetails(BuildContext context) {
    final provider = Provider.of<CoffeeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          task.name,
          style: const TextStyle(fontFamily: 'RobotoMono'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${_getTypeDescription()}',
              style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Interval: ${_getIntervalDescription()}',
              style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress: ${_getProgressDescription(provider)}',
              style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14),
            ),
            if (task.lastCompleted != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last completed: ${DateFormat('MMM d, yyyy').format(task.lastCompleted!)}',
                style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteMaintenanceTask(task.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.completeMaintenanceTask(task.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task marked as completed')),
              );
            },
            child: const Text('Mark Complete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getTypeDescription() {
    switch (task.type) {
      case MaintenanceType.clean:
        return 'Clean';
      case MaintenanceType.decalcify:
        return 'Decalcify';
      case MaintenanceType.checkMachine:
        return 'Check Machine';
      case MaintenanceType.checkGrinder:
        return 'Check Grinder';
    }
  }
}

class _AddMaintenanceTaskDialog extends StatefulWidget {
  const _AddMaintenanceTaskDialog();

  @override
  State<_AddMaintenanceTaskDialog> createState() =>
      _AddMaintenanceTaskDialogState();
}

class _AddMaintenanceTaskDialogState extends State<_AddMaintenanceTaskDialog> {
  final _nameController = TextEditingController();
  final _intervalController = TextEditingController();
  MaintenanceType _selectedType = MaintenanceType.clean;
  MaintenanceIntervalType _selectedIntervalType = MaintenanceIntervalType.shots;

  @override
  void dispose() {
    _nameController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Maintenance Task',
        style: TextStyle(fontFamily: 'RobotoMono'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'e.g., Clean espresso machine',
              ),
              style: const TextStyle(fontFamily: 'RobotoMono'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MaintenanceType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: MaintenanceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    _getTypeLabel(type),
                    style: const TextStyle(fontFamily: 'RobotoMono'),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MaintenanceIntervalType>(
              value: _selectedIntervalType,
              decoration: const InputDecoration(labelText: 'Interval Type'),
              items: MaintenanceIntervalType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    _getIntervalTypeLabel(type),
                    style: const TextStyle(fontFamily: 'RobotoMono'),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedIntervalType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _intervalController,
              decoration: InputDecoration(
                labelText: 'Interval Value',
                hintText: _getIntervalHint(),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontFamily: 'RobotoMono'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _intervalController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }

            final interval = int.tryParse(_intervalController.text);
            if (interval == null || interval <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid interval')),
              );
              return;
            }

            final task = MaintenanceTask(
              name: _nameController.text,
              type: _selectedType,
              intervalType: _selectedIntervalType,
              intervalValue: interval,
            );

            Provider.of<CoffeeProvider>(
              context,
              listen: false,
            ).addMaintenanceTask(task);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _getTypeLabel(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.clean:
        return 'Clean';
      case MaintenanceType.decalcify:
        return 'Decalcify';
      case MaintenanceType.checkMachine:
        return 'Check Machine';
      case MaintenanceType.checkGrinder:
        return 'Check Grinder';
    }
  }

  String _getIntervalTypeLabel(MaintenanceIntervalType type) {
    switch (type) {
      case MaintenanceIntervalType.shots:
        return 'Shots';
      case MaintenanceIntervalType.days:
        return 'Days';
      case MaintenanceIntervalType.waterLiters:
        return 'Water (Liters)';
    }
  }

  String _getIntervalHint() {
    switch (_selectedIntervalType) {
      case MaintenanceIntervalType.shots:
        return 'e.g., 100';
      case MaintenanceIntervalType.days:
        return 'e.g., 30';
      case MaintenanceIntervalType.waterLiters:
        return 'e.g., 100';
    }
  }
}
