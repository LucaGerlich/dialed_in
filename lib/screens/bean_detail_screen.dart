import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';
import 'add_shot_screen.dart';

class BeanDetailScreen extends StatelessWidget {
  final String beanId;

  const BeanDetailScreen({super.key, required this.beanId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        final bean = provider.beans.firstWhere(
          (b) => b.id == beanId,
          orElse: () => Bean(name: 'Deleted'), // Handle deletion gracefully
        );

        if (bean.name == 'Deleted') {
          return const Scaffold(body: Center(child: Text('Bean not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(bean.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Confirm delete
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Bean?'),
                      content: const Text('This will delete the bean and all its shots.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.deleteBean(bean.id);
                            Navigator.pop(ctx); // Close dialog
                            Navigator.pop(context); // Go back to list
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bean.notes.isNotEmpty) ...[
                      Text('Notes:', style: Theme.of(context).textTheme.titleMedium),
                      Text(bean.notes),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Preferred Grind Size: ${bean.preferredGrindSize?.toString() ?? "Not set"}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Shot History', style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: bean.shots.length,
                  itemBuilder: (context, index) {
                    final shot = bean.shots[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(shot.grindSize.toString()),
                      ),
                      title: Text('${shot.doseIn}g in -> ${shot.doseOut}g out'),
                      subtitle: Text('${shot.duration}s - ${DateFormat.yMMMd().add_jm().format(shot.timestamp)}'),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddShotScreen(beanId: bean.id),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
