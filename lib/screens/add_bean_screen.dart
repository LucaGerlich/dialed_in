import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bean?.name ?? '');
    _originController = TextEditingController(text: widget.bean?.origin ?? '');
    _processController = TextEditingController(text: widget.bean?.process ?? '');
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
      _customFlavorValues = Map.from(widget.bean!.customFlavorValues);
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
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _flavourTags.remove(tag);
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
        customFlavorValues: _customFlavorValues,
      );

      if (widget.bean != null) {
        Provider.of<CoffeeProvider>(context, listen: false).updateBean(bean);
      } else {
        Provider.of<CoffeeProvider>(context, listen: false).addBean(bean);
      }
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bean != null ? 'Edit Bean' : 'Add Bean'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('BEAN NAME'),
            _buildTextField(_nameController, 'e.g. Ethiopia Yirgacheffe'),
            const SizedBox(height: 24),
            
            _buildLabel('ORIGIN'),
            _buildTextField(_originController, 'e.g. Ethiopia'),
            const SizedBox(height: 24),

            _buildLabel('ROAST DATE'),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _roastDate == null
                          ? 'Select Date'
                          : '${_roastDate!.day}/${_roastDate!.month}/${_roastDate!.year}',
                      style: TextStyle(
                        color: _roastDate == null ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6) : Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('ROAST LEVEL'),
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
                      if (selected) setState(() => _roastLevel = level);
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            _buildLabel('PROCESS'),
            _buildTextField(_processController, 'e.g. Washed, Natural'),
            const SizedBox(height: 24),

            _buildLabel('NOTES'),
            _buildTextField(_notesController, 'Tasting notes, etc.', maxLines: 3),
            const SizedBox(height: 24),

            _buildLabel('FLAVOR PROFILE'),
            _buildSlider('Acidity', _acidity, (val) => setState(() => _acidity = val)),
            _buildSlider('Body', _body, (val) => setState(() => _body = val)),
            _buildSlider('Sweetness', _sweetness, (val) => setState(() => _sweetness = val)),
            _buildSlider('Bitterness', _bitterness, (val) => setState(() => _bitterness = val)),
            _buildSlider('Aftertaste', _aftertaste, (val) => setState(() => _aftertaste = val)),
            // Custom flavor attributes from settings
            Consumer<CoffeeProvider>(
              builder: (context, provider, child) {
                final customAttrs = provider.customFlavorAttributes;
                if (customAttrs.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: customAttrs.map((attr) {
                    // Initialize custom value if not present
                    _customFlavorValues[attr] ??= 5.0;
                    return _buildSlider(
                      attr,
                      _customFlavorValues[attr]!,
                      (val) => setState(() => _customFlavorValues[attr] = val),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            _buildLabel('FLAVOR TAGS'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_tagController, 'Add a tag (e.g. Blueberry)'),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _flavourTags.map((tag) {
                return Chip(
                  label: Text(tag, style: TextStyle(fontFamily: 'RobotoMono',fontSize: 12, color: Theme.of(context).colorScheme.onPrimary)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  deleteIcon: Icon(Icons.close, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                  onDeleted: () => _removeTag(tag),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(widget.bean != null ? 'UPDATE BEAN' : 'ADD BEAN', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
            Text(value.toStringAsFixed(1), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            thumbColor: Theme.of(context).colorScheme.onSurface,
            overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
        style: TextStyle(fontFamily: 'RobotoMono',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
