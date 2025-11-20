import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coffee_provider.dart';
import 'add_bean_screen.dart';
import 'bean_detail_screen.dart';
import '../widgets/bean_card.dart';

class BeanListScreen extends StatelessWidget {
  const BeanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bean Vault'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {}, // No back action on home, but keeping icon for visual match
        ),
      ),
      body: Consumer<CoffeeProvider>(
        builder: (context, provider, child) {
          if (provider.beans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.coffee_maker, size: 64, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(height: 16),
                  Text(
                    'No beans yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first bag of coffee!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.beans.length,
            itemBuilder: (context, index) {
              final bean = provider.beans[index];
              return BeanCard(
                bean: bean,
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
