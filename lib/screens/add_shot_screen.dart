import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';

class AddShotScreen extends StatefulWidget {
  final String beanId;

  const AddShotScreen({super.key, required this.beanId});

  @override
  State<AddShotScreen> createState() => _AddShotScreenState();
}

class _AddShotScreenState extends State<AddShotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _grindSizeController = TextEditingController();
  final _doseInController = TextEditingController();
  final _doseOutController = TextEditingController();
  final _durationController = TextEditingController();
  bool _updatePreferred = false;

  @override
  void dispose() {
    _grindSizeController.dispose();
    _doseInController.dispose();
    _doseOutController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveShot() {
    if (_formKey.currentState!.validate()) {
      final shot = Shot(
        grindSize: double.parse(_grindSizeController.text),
        doseIn: double.parse(_doseInController.text),
        doseOut: double.parse(_doseOutController.text),
        duration: int.parse(_durationController.text),
        timestamp: DateTime.now(),
      );

      Provider.of<CoffeeProvider>(context, listen: false).addShot(
        widget.beanId,
        shot,
        updatePreferredGrind: _updatePreferred,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _grindSizeController,
                decoration: const InputDecoration(labelText: 'Grind Size'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _doseInController,
                decoration: const InputDecoration(labelText: 'Dose In (g)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _doseOutController,
                decoration: const InputDecoration(labelText: 'Dose Out (g)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Time (s)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Invalid integer';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Update Preferred Grind Size'),
                value: _updatePreferred,
                onChanged: (val) {
                  setState(() {
                    _updatePreferred = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveShot,
                child: const Text('Save Shot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
