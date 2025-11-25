import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';

class GearSettingsScreen extends StatelessWidget {
  const GearSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear Settings'),
      ),
      body: Consumer<CoffeeProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, 'Coffee Machines'),
              ...provider.machines.map((machine) => _buildGearItem(
                    context,
                    machine.name,
                    () => provider.deleteMachine(machine.id),
                  )),
              _buildAddButton(context, 'Add Machine', (data) {
                provider.addMachine(CoffeeMachine(
                  name: data['name'],
                  defaultPressure: data['pressure'],
                  defaultTemperature: data['temp'],
                  defaultPreInfusionTime: data['preInfusion'],
                ));
              }, isMachine: true),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Grinders'),
              ...provider.grinders.map((grinder) => _buildGearItem(
                    context,
                    grinder.name,
                    () => provider.deleteGrinder(grinder.id),
                  )),
              _buildAddButton(context, 'Add Grinder', (data) {
                provider.addGrinder(Grinder(
                  name: data['name'],
                  defaultRpm: data['rpm'],
                ));
              }, isMachine: false),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Grind Settings'),
              _buildGrindSettings(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.robotoMono(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildGearItem(BuildContext context, String name, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, String label, Function(Map<String, dynamic>) onAdd, {bool isMachine = false}) {
    return OutlinedButton.icon(
      onPressed: () => _showAddDialog(context, label, onAdd, isMachine: isMachine),
      icon: const Icon(Icons.add),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _showAddDialog(BuildContext context, String title, Function(Map<String, dynamic>) onAdd, {required bool isMachine}) {
    final nameController = TextEditingController();
    final pressureController = TextEditingController();
    final tempController = TextEditingController();
    final preInfusionController = TextEditingController();
    final rpmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 16),
              if (isMachine) ...[
                TextField(
                  controller: pressureController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Default Pressure (bar)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tempController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Default Temp (°C)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: preInfusionController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Default Pre-Infusion (s)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
              ] else ...[
                 TextField(
                  controller: rpmController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Default RPM',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final data = <String, dynamic>{
                  'name': nameController.text,
                };
                
                if (isMachine) {
                  if (pressureController.text.isNotEmpty) data['pressure'] = double.tryParse(pressureController.text);
                  if (tempController.text.isNotEmpty) data['temp'] = double.tryParse(tempController.text);
                  if (preInfusionController.text.isNotEmpty) data['preInfusion'] = int.tryParse(preInfusionController.text);
                } else {
                  if (rpmController.text.isNotEmpty) data['rpm'] = double.tryParse(rpmController.text);
                }

                onAdd(data);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrindSettings(BuildContext context, CoffeeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSettingInput(context, 'Min', provider.grindMin.toString(), (val) {
                final min = double.tryParse(val);
                if (min != null) provider.updateGrindSettings(min, provider.grindMax, provider.grindStep);
              })),
              const SizedBox(width: 16),
              Expanded(child: _buildSettingInput(context, 'Max', provider.grindMax.toString(), (val) {
                final max = double.tryParse(val);
                if (max != null) provider.updateGrindSettings(provider.grindMin, max, provider.grindStep);
              })),
              const SizedBox(width: 16),
              Expanded(child: _buildSettingInput(context, 'Step', provider.grindStep.toString(), (val) {
                final step = double.tryParse(val);
                if (step != null) provider.updateGrindSettings(provider.grindMin, provider.grindMax, step);
              })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingInput(BuildContext context, String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
