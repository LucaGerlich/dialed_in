import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';

class AddBeanScreen extends StatefulWidget {
  final Bean? bean;

  const AddBeanScreen({super.key, this.bean});

  @override
  State<AddBeanScreen> createState() => _AddBeanScreenState();
}

class _AddBeanScreenState extends State<AddBeanScreen> {
  late TextEditingController _nameController;
  late TextEditingController _originController;
  late TextEditingController _processController;
  late TextEditingController _notesController;
  final TextEditingController _tagController = TextEditingController();

  String _roastLevel = 'Medium';
  final List<String> _roastLevels = ['Light', 'Medium', 'Dark'];
  DateTime? _roastDate;
  List<String> _flavourTags = [];

  // Flavor Profile Values
  double _acidity = 5.0;
  double _body = 5.0;
  double _sweetness = 5.0;
  double _bitterness = 5.0;
  double _aftertaste = 5.0;

  // Custom Flavor Values
  Map<String, double> _customFlavorValues = {};

  // Bean Composition
  double _arabicaPercentage = 100.0;
  double _robustaPercentage = 0.0;

  // Ranking (0 = unranked, 1-5 = star rating)
  int _ranking = 0;

  // Image path
  String? _imagePath;

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bean?.name ?? '');
    _originController = TextEditingController(text: widget.bean?.origin ?? '');
    _processController = TextEditingController(
      text: widget.bean?.process ?? '',
    );
    _notesController = TextEditingController(text: widget.bean?.notes ?? '');
    if (widget.bean != null) {
      _roastLevel = widget.bean!.roastLevel;
      _roastDate = widget.bean!.roastDate;
      _flavourTags = List.from(widget.bean!.flavourTags);
      _acidity = widget.bean!.acidity;
      _body = widget.bean!.body;
      _sweetness = widget.bean!.sweetness;
      _bitterness = widget.bean!.bitterness;
      _aftertaste = widget.bean!.aftertaste;
      _arabicaPercentage = widget.bean!.arabicaPercentage;
      _robustaPercentage = widget.bean!.robustaPercentage;
      _customFlavorValues = Map.from(widget.bean!.customFlavorValues);
      _ranking = widget.bean!.ranking;
      _imagePath = widget.bean!.imagePath;
    }

    // Track unsaved changes via text controllers
    void markChanged() {
      if (!_hasUnsavedChanges) {
        setState(() => _hasUnsavedChanges = true);
      }
    }
    _nameController.addListener(markChanged);
    _originController.addListener(markChanged);
    _processController.addListener(markChanged);
    _notesController.addListener(markChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<CoffeeProvider>(context, listen: false);
    final currentCustomAttrs = provider.customFlavorAttributes.toSet();

    // Remove any custom flavor values for attributes that no longer exist in settings
    _customFlavorValues.removeWhere(
      (key, _) => !currentCustomAttrs.contains(key),
    );

    // Initialize custom flavor values for any new custom attributes
    for (final attr in currentCustomAttrs) {
      _customFlavorValues[attr] ??= 5.0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _processController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _flavourTags.add(_tagController.text.trim());
        _tagController.clear();
        _hasUnsavedChanges = true;
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _flavourTags.remove(tag);
      _hasUnsavedChanges = true;
    });
  }

  void _saveBean() {
    if (_nameController.text.isNotEmpty) {
      final bean = Bean(
        id: widget.bean?.id, // Keep ID if editing
        name: _nameController.text,
        origin: _originController.text,
        roastLevel: _roastLevel,
        process: _processController.text,
        notes: _notesController.text,
        roastDate: _roastDate,
        shots: widget.bean?.shots, // Keep shots if editing
        preferredGrindSize: widget.bean?.preferredGrindSize ?? 10.0,
        flavourTags: _flavourTags,
        acidity: _acidity,
        body: _body,
        sweetness: _sweetness,
        bitterness: _bitterness,
        aftertaste: _aftertaste,
        arabicaPercentage: _arabicaPercentage,
        robustaPercentage: _robustaPercentage,
        customFlavorValues: _customFlavorValues,
        ranking: _ranking,
        imagePath: _imagePath,
      );

      if (widget.bean != null) {
        Provider.of<CoffeeProvider>(context, listen: false).updateBean(bean);
      } else {
        Provider.of<CoffeeProvider>(context, listen: false).addBean(bean);
      }
      _hasUnsavedChanges = false;
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _roastDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _roastDate) {
      setState(() {
        _roastDate = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      // Copy image to app's documents directory for persistence
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'bean_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final savedImage = await File(image.path).copy('${directory.path}/$fileName');
      setState(() {
        _imagePath = savedImage.path;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _hasUnsavedChanges = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discard, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.bean != null ? l10n.editBean : l10n.addBean),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          TextButton(
            onPressed: _nameController.text.isNotEmpty ? _saveBean : null,
            child: Text(
              widget.bean != null ? l10n.updateBeanButton : l10n.addBeanButton,
              style: TextStyle(
                color: _nameController.text.isNotEmpty
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildLabel(l10n.beanImage),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  image: _imagePath != null && File(_imagePath!).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(_imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imagePath == null || !File(_imagePath!).existsSync()
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.tapToAddPhoto,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                            onPressed: _removeImage,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel(l10n.beanName),
            _buildTextField(_nameController, l10n.beanNameHint),
            const SizedBox(height: 24),

            _buildLabel(l10n.ranking),
            const SizedBox(height: 8),
            _buildStarRating(),
            const SizedBox(height: 24),

            _buildLabel(l10n.origin),
            _buildTextField(_originController, l10n.originHint),
            const SizedBox(height: 24),

            _buildLabel(l10n.roastDate),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _roastDate == null
                          ? l10n.selectDate
                          : '${_roastDate!.day}/${_roastDate!.month}/${_roastDate!.year}',
                      style: TextStyle(
                        color: _roastDate == null
                            ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6)
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel(l10n.roastLevel),
            const SizedBox(height: 8),
            Row(
              children: _roastLevels.map((level) {
                final isSelected = _roastLevel == level;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() { _roastLevel = level; _hasUnsavedChanges = true; });
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            _buildLabel(l10n.process),
            _buildTextField(_processController, l10n.processHint),
            const SizedBox(height: 24),

            _buildLabel(l10n.beanComposition),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.arabica,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                inactiveTrackColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.1),
                                thumbColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                overlayColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: _arabicaPercentage,
                                min: 0.0,
                                max: 100.0,
                                divisions: 20,
                                label:
                                    '${_arabicaPercentage.toStringAsFixed(0)}%',
                                onChanged: (val) {
                                  setState(() {
                                    _arabicaPercentage = val;
                                    _robustaPercentage = 100.0 - val;
                                    _hasUnsavedChanges = true;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${_arabicaPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.robusta,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                inactiveTrackColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.1),
                                thumbColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                overlayColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: _robustaPercentage,
                                min: 0.0,
                                max: 100.0,
                                divisions: 20,
                                label:
                                    '${_robustaPercentage.toStringAsFixed(0)}%',
                                onChanged: (val) {
                                  setState(() {
                                    _robustaPercentage = val;
                                    _arabicaPercentage = 100.0 - val;
                                    _hasUnsavedChanges = true;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${_robustaPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel(l10n.notes),
            _buildTextField(_notesController, l10n.notesHint, maxLines: 3),
            const SizedBox(height: 24),

            _buildLabel(l10n.flavorProfile),
            _buildSlider(
              l10n.acidity,
              _acidity,
              (val) => setState(() { _acidity = val; _hasUnsavedChanges = true; }),
            ),
            _buildSlider(
              l10n.body,
              _body,
              (val) => setState(() { _body = val; _hasUnsavedChanges = true; }),
            ),
            _buildSlider(
              l10n.sweetness,
              _sweetness,
              (val) => setState(() { _sweetness = val; _hasUnsavedChanges = true; }),
            ),
            _buildSlider(
              l10n.bitterness,
              _bitterness,
              (val) => setState(() { _bitterness = val; _hasUnsavedChanges = true; }),
            ),
            _buildSlider(
              l10n.aftertaste,
              _aftertaste,
              (val) => setState(() { _aftertaste = val; _hasUnsavedChanges = true; }),
            ),
            // Custom flavor attributes from settings
            Consumer<CoffeeProvider>(
              builder: (context, provider, child) {
                final customAttrs = provider.customFlavorAttributes;
                if (customAttrs.isEmpty) return const SizedBox.shrink();
                // Build sliders using current values (initialized in didChangeDependencies)
                return Column(
                  children: customAttrs.map((attr) {
                    return _buildSlider(
                      attr,
                      _customFlavorValues[attr] ?? 5.0,
                      (val) => setState(() { _customFlavorValues[attr] = val; _hasUnsavedChanges = true; }),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            _buildLabel(l10n.flavorTags),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_tagController, l10n.flavorTagHint),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _flavourTags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  deleteIcon: Icon(
                    Icons.close,
                    size: 14,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onDeleted: () => _removeTag(tag),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBean,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.bean != null
                      ? l10n.updateBeanButton
                      : l10n.addBeanButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = _ranking >= starIndex;
        return GestureDetector(
          onTap: () {
            setState(() {
              // Tapping the same star again resets to unranked
              if (_ranking == starIndex) {
                _ranking = 0;
              } else {
                _ranking = starIndex;
              }
              _hasUnsavedChanges = true;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: 36,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            thumbColor: Theme.of(context).colorScheme.onSurface,
            overlayColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 10.0,
            divisions: 100,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
