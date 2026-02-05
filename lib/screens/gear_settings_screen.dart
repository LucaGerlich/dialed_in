import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';
import '../models/models.dart';
import 'package:dialed_in/providers/coffee_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GearSettingsScreen extends StatelessWidget {
  const GearSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.gearSettings)),
      body: Consumer<CoffeeProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, l10n.appSettings),
              _buildThemeDropdown(context, provider),
              const SizedBox(height: 16),
              _buildLanguageDropdown(context, provider),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.coffeeMachines),
              ...provider.machines.map(
                (machine) => _buildGearItem(
                  context,
                  machine.name,
                  () => provider.deleteMachine(machine.id),
                ),
              ),
              _buildAddButton(context, l10n.addMachine, (data) {
                provider.addMachine(
                  CoffeeMachine(
                    name: data['name'],
                    defaultPressure: data['pressure'],
                    defaultTemperature: data['temp'],
                    defaultPreInfusionTime: data['preInfusion'],
                  ),
                );
              }, isMachine: true),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.grinders),
              ...provider.grinders.map(
                (grinder) => _buildGearItem(
                  context,
                  grinder.name,
                  () => provider.deleteGrinder(grinder.id),
                ),
              ),
              _buildAddButton(context, l10n.addGrinder, (data) {
                provider.addGrinder(
                  Grinder(name: data['name'], defaultRpm: data['rpm']),
                );
              }, isMachine: false),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.grindSettings),
              _buildGrindSettings(context, provider),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.flavorProfile),
              _buildFlavorProfileSettings(context, provider),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.dataManagement),
              _buildDataManagementSection(context, provider),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.help),
              _buildHelpSection(context, provider),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.aboutDialedIn),
              _buildAboutSection(context),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context, CoffeeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              // Reset onboarding and navigate back to trigger it
              await provider.resetOnboarding();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.viewAppTutorial,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.learnHowToUse,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeDropdown(BuildContext context, CoffeeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ThemeMode>(
          value: provider.themeMode,
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surface,
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text(l10n.systemTheme),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text(l10n.lightTheme),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark, 
              child: Text(l10n.darkTheme),
            ),
          ],
          onChanged: (mode) {
            if (mode != null) provider.setThemeMode(mode);
          },
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, CoffeeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    
    // Map of locale codes to display names
    final localeOptions = {
      null: l10n.systemDefault,
      const Locale('en'): l10n.english,
      const Locale('es'): l10n.spanish,
      const Locale('de'): l10n.german,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale?>(
          value: provider.locale,
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surface,
          items: localeOptions.entries.map((entry) {
            return DropdownMenuItem<Locale?>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (locale) {
            provider.setLocale(locale);
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildGearItem(
    BuildContext context,
    String name,
    VoidCallback onDelete,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    String label,
    Function(Map<String, dynamic>) onAdd, {
    bool isMachine = false,
  }) {
    return OutlinedButton.icon(
      onPressed: () =>
          _showAddDialog(context, label, onAdd, isMachine: isMachine),
      icon: const Icon(Icons.add),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    String title,
    Function(Map<String, dynamic>) onAdd, {
    required bool isMachine,
  }) {
    final nameController = TextEditingController();
    final pressureController = TextEditingController();
    final tempController = TextEditingController();
    final preInfusionController = TextEditingController();
    final rpmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isMachine) ...[
                TextField(
                  controller: pressureController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Default Pressure (bar)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tempController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Default Temp (°C)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: preInfusionController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Default Pre-Infusion (s)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: rpmController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Default RPM',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
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
                final data = <String, dynamic>{'name': nameController.text};

                if (isMachine) {
                  if (pressureController.text.isNotEmpty)
                    data['pressure'] = double.tryParse(pressureController.text);
                  if (tempController.text.isNotEmpty)
                    data['temp'] = double.tryParse(tempController.text);
                  if (preInfusionController.text.isNotEmpty)
                    data['preInfusion'] = int.tryParse(
                      preInfusionController.text,
                    );
                } else {
                  if (rpmController.text.isNotEmpty)
                    data['rpm'] = double.tryParse(rpmController.text);
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
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSettingInput(
                  context,
                  'Min',
                  provider.grindMin.toString(),
                  (val) {
                    final min = double.tryParse(val);
                    if (min != null)
                      provider.updateGrindSettings(
                        min,
                        provider.grindMax,
                        provider.grindStep,
                      );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSettingInput(
                  context,
                  'Max',
                  provider.grindMax.toString(),
                  (val) {
                    final max = double.tryParse(val);
                    if (max != null)
                      provider.updateGrindSettings(
                        provider.grindMin,
                        max,
                        provider.grindStep,
                      );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSettingInput(
                  context,
                  'Step',
                  provider.grindStep.toString(),
                  (val) {
                    final step = double.tryParse(val);
                    if (step != null)
                      provider.updateGrindSettings(
                        provider.grindMin,
                        provider.grindMax,
                        step,
                      );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlavorProfileSettings(
    BuildContext context,
    CoffeeProvider provider,
  ) {
    final defaultAttributes = [
      'Acidity',
      'Body',
      'Sweetness',
      'Bitterness',
      'Aftertaste',
    ];
    final customAttributes = provider.customFlavorAttributes;
    final canAddMore = customAttributes.length < 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default attributes are always shown. Add up to 3 custom attributes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DEFAULT ATTRIBUTES',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: defaultAttributes
                .map(
                  (attr) => Chip(
                    label: Text(
                      attr,
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'CUSTOM ATTRIBUTES (${customAttributes.length}/3)',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          if (customAttributes.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: customAttributes
                  .map(
                    (attr) => Chip(
                      label: Text(
                        attr,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      deleteIcon: Icon(
                        Icons.close,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onDeleted: () =>
                          provider.removeCustomFlavorAttribute(attr),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (canAddMore)
            OutlinedButton.icon(
              onPressed: () => _showAddCustomAttributeDialog(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Attribute'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddCustomAttributeDialog(
    BuildContext context,
    CoffeeProvider provider,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Add Custom Attribute',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Attribute Name',
            hintText: 'e.g. Fruity, Nutty, Floral',
            labelStyle: const TextStyle(color: Colors.grey),
            hintStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final success = provider.addCustomFlavorAttribute(name);
                if (success) {
                  Navigator.pop(ctx);
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cannot add "$name". It may be a duplicate or conflict with a default attribute.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingInput(
    BuildContext context,
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(
    BuildContext context,
    CoffeeProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export and import your brew logs as JSON for backup or external analysis.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportData(context, provider),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Export'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _importData(context, provider),
                  icon: const Icon(Icons.download),
                  label: const Text('Import'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(
    BuildContext context,
    CoffeeProvider provider,
  ) async {
    try {
      final filePath = await provider.exportDataToFile();

      if (context.mounted) {
        // ignore: deprecated_member_use
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Dialed In - Coffee Data Export');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importData(
    BuildContext context,
    CoffeeProvider provider,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled the picker
      }

      final file = result.files.first;
      String jsonContent;

      if (file.bytes != null) {
        // For web platform
        jsonContent = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        // For native platforms
        jsonContent = await File(file.path!).readAsString();
      } else {
        throw Exception('Unable to read file');
      }

      if (context.mounted) {
        // Show confirmation dialog
        final shouldReplace = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Import Data',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Do you want to replace all existing data or merge with current data?',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Merge'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Replace'),
              ),
            ],
          ),
        );

        if (shouldReplace != null && context.mounted) {
          await provider.importDataFromJson(
            jsonContent,
            replaceExisting: shouldReplace,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  shouldReplace
                      ? 'Data imported successfully!'
                      : 'Data merged successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dialed In is a companion for specialty coffee enthusiasts. Track your beans, record every shot, and master the art of the perfect extraction.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.code,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Built by Luca Gerlich',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => launchUrl(
              Uri.parse('https://github.com/LucaGerlich/dialed_in'),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'GitHub Project',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.1.0',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
