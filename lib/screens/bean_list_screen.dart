import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coffee_provider.dart';
import 'add_bean_screen.dart';
import 'bean_detail_screen.dart';

class BeanListScreen extends StatelessWidget {
  const BeanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dialed In'),
      ),
      body: Consumer<CoffeeProvider>(
        builder: (context, provider, child) {
          if (provider.beans.isEmpty) {
            return const Center(
              child: Text('No beans yet. Add one!'),
            );
          }
          return ListView.builder(
            itemCount: provider.beans.length,
            itemBuilder: (context, index) {
              final bean = provider.beans[index];
              return ListTile(
                title: Text(bean.name),
                subtitle: Text(bean.preferredGrindSize != null
                    ? 'Grind: ${bean.preferredGrindSize}'
                    : 'No grind set'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BeanDetailScreen(beanId: bean.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBeanScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
