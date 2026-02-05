import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';
import '../widgets/analog_dial.dart';

class AddShotScreen extends StatefulWidget {
  final String beanId;

  const AddShotScreen({super.key, required this.beanId});

  @override
  State<AddShotScreen> createState() => _AddShotScreenState();
}

class _AddShotScreenState extends State<AddShotScreen> {
  final _doseInController = TextEditingController(text: '18.0');
  final _doseOutController = TextEditingController(text: '36.0');
  final _durationController = TextEditingController(text: '00:00.0');

  // Advanced Params Controllers
  final _rpmController = TextEditingController();
  final _pressureController = TextEditingController();
  final _tempController = TextEditingController();
  final _preInfusionController = TextEditingController();
  final _waterController = TextEditingController();

  double _grindSize = 10.0;
  int _durationMs = 0; // Duration in milliseconds
  Timer? _timer;
  bool _isTimerRunning = false;
  final bool _updatePreferred =
      false; // Fixed: made final as it's never changed

  String? _selectedMachineId;
  String? _selectedGrinderId;

  // Flavour Coordinates (-1 to 1)
  double _flavourX = 0;
  double _flavourY = 0;

  @override
  void initState() {
    super.initState();
    // Initialize grind size from the last shot or bean's preferred size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CoffeeProvider>(context, listen: false);
      final bean = provider.beans.firstWhere((b) => b.id == widget.beanId);

      // Use grind size from the most recent shot (shots are sorted newest first)
      // or fall back to preferred size
      final initialGrindSize = bean.shots.isNotEmpty
          ? bean.shots.first.grindSize
          : bean.preferredGrindSize;

      setState(() {
        _grindSize = initialGrindSize;
      });
    });
  }

  @override
  void dispose() {
    _doseInController.dispose();
    _doseOutController.dispose();
    _durationController.dispose();
    _rpmController.dispose();
    _pressureController.dispose();
    _tempController.dispose();
    _preInfusionController.dispose();
    _waterController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    } else {
      setState(() {
        _isTimerRunning = true;
        _durationMs = 0; // Reset duration
        _durationController.text = _formatDuration(_durationMs);
      });
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        // Update faster
        setState(() {
          _durationMs += 100; // Increment by 100ms
          _durationController.text = _formatDuration(_durationMs);
        });
      });
    }
  }

  void _showTimePicker() {
    if (_isTimerRunning) return;

    final l10n = AppLocalizations.of(context)!;

    // Convert current duration to minutes, seconds, tenths
    int totalSeconds = _durationMs ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    int tenths = (_durationMs % 1000) ~/ 100;

    int selectedMinute = minutes;
    int selectedSecond = seconds;
    int selectedTenth = tenths;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            // Toolbar
            Container(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(l10n.cancel),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text(l10n.done),
                    onPressed: () {
                      setState(() {
                        _durationMs =
                            selectedMinute * 60 * 1000 +
                            selectedSecond * 1000 +
                            selectedTenth * 100;
                        _durationController.text = _formatDuration(_durationMs);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // Picker
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minutes
                  SizedBox(
                    width: 60,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: minutes,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        selectedMinute = index;
                      },
                      children: List.generate(
                        10,
                        (i) => Center(
                          child: Text(
                            i.toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(':', style: TextStyle(fontSize: 20)),
                  // Seconds
                  SizedBox(
                    width: 60,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: seconds,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        selectedSecond = index;
                      },
                      children: List.generate(
                        60,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text('.', style: TextStyle(fontSize: 20)),
                  // Tenths
                  SizedBox(
                    width: 40,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: tenths,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        selectedTenth = index;
                      },
                      children: List.generate(
                        10,
                        (i) => Center(
                          child: Text(
                            i.toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveShot() {
    final l10n = AppLocalizations.of(context)!;
    final doseIn = double.tryParse(_doseInController.text) ?? 0.0;
    final doseOut = double.tryParse(_doseOutController.text) ?? 0.0;

    if (doseIn > 0 && doseOut > 0 && _durationMs > 0) {
      final shot = Shot(
        grindSize: _grindSize,
        doseIn: doseIn,
        doseOut: doseOut,
        duration: _durationMs ~/ 1000, // Convert back to seconds for Shot model
        timestamp: DateTime.now(),
        grinderRpm: double.tryParse(_rpmController.text),
        pressure: double.tryParse(_pressureController.text),
        temperature: double.tryParse(_tempController.text),
        preInfusionTime: int.tryParse(_preInfusionController.text),
        machineId: _selectedMachineId,
        grinderId: _selectedGrinderId,
        water: _waterController.text.isNotEmpty ? _waterController.text : null,
        flavourX: _flavourX,
        flavourY: _flavourY,
      );

      Provider.of<CoffeeProvider>(
        context,
        listen: false,
      ).addShot(widget.beanId, shot, updatePreferredGrind: _updatePreferred);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllFields)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<CoffeeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addShot)),
      body: Stack(
        children: [
          // Expanded Dial Area (Background)
          Positioned.fill(
            //bottom: 300, // Reserve space for the minimized sheet header
            top: -500,
            child: Center(
              child: AnalogDial(
                value: _grindSize,
                min: provider.grindMin,
                max: provider.grindMax,
                step: provider.grindStep,
                label: l10n.grindSize,
                onChanged: (val) {
                  setState(() {
                    _grindSize = val;
                  });
                },
              ),
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.90,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Timer Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: TextField(
                                        controller: _durationController,
                                        enabled: !_isTimerRunning,
                                        readOnly: true,
                                        onTap: _showTimePicker,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'RobotoMono',
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: _toggleTimer,
                                      child: Text(
                                        _isTimerRunning ? 'STOP' : 'START',
                                        style: TextStyle(
                                          color: _isTimerRunning
                                              ? Colors.red
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Dose Inputs
                            Expanded(
                              child: Column(
                                children: [
                                  _buildCompactInput(
                                    context,
                                    l10n.doseInShort, // "IN"
                                    _doseInController,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildCompactInput(
                                    context,
                                    l10n.doseOutShort, // "OUT"
                                    _doseOutController,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Gear Selection
                        if (provider.machines.isNotEmpty ||
                            provider.grinders.isNotEmpty) ...[
                          Text(
                            l10n.gear,
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (provider.machines.isNotEmpty)
                                Expanded(
                                  child: InputDecorator(
                                    decoration: _inputDecoration(
                                      context,
                                      l10n.machine,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        isDense: true,
                                        value: _selectedMachineId,
                                        dropdownColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                        items: provider.machines
                                            .map(
                                              (m) => DropdownMenuItem(
                                                value: m.id,
                                                child: Text(
                                                  m.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedMachineId = val;
                                            final machine = provider.machines
                                                .firstWhere((m) => m.id == val);
                                            if (machine.defaultPressure !=
                                                null) {
                                              _pressureController.text = machine
                                                  .defaultPressure
                                                  .toString();
                                            }
                                            if (machine.defaultTemperature !=
                                                null) {
                                              _tempController.text = machine
                                                  .defaultTemperature
                                                  .toString();
                                            }
                                            if (machine
                                                    .defaultPreInfusionTime !=
                                                null) {
                                              _preInfusionController.text =
                                                  machine.defaultPreInfusionTime
                                                      .toString();
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              if (provider.machines.isNotEmpty &&
                                  provider.grinders.isNotEmpty)
                                const SizedBox(width: 12),
                              if (provider.grinders.isNotEmpty)
                                Expanded(
                                  child: InputDecorator(
                                    decoration: _inputDecoration(
                                      context,
                                      l10n.grinder,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        isDense: true,
                                        value: _selectedGrinderId,
                                        dropdownColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                        items: provider.grinders
                                            .map(
                                              (g) => DropdownMenuItem(
                                                value: g.id,
                                                child: Text(
                                                  g.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedGrinderId = val;
                                            final grinder = provider.grinders
                                                .firstWhere((g) => g.id == val);
                                            if (grinder.defaultRpm != null) {
                                              _rpmController.text = grinder
                                                  .defaultRpm
                                                  .toString();
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Advanced Params
                        ExpansionTile(
                          title: Text(
                            l10n.extractionParameters,
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          children: [
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCompactInput(
                                    context,
                                    l10n.rpm,
                                    _rpmController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactInput(
                                    context,
                                    l10n.pressure,
                                    _pressureController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCompactInput(
                                    context,
                                    l10n.temp,
                                    _tempController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactInput(
                                    context,
                                    l10n.preInfusion,
                                    _preInfusionController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildCompactInput(
                              context,
                              l10n.water,
                              _waterController,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Flavour Graph
                        ExpansionTile(
                          title: Text(
                            l10n.tasteProfile,
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      // Map local position to -1 to 1
                                      // This is tricky inside a scroll view, let's use relative position
                                      // Assuming 200x200 box
                                      double dx = details.localPosition.dx;
                                      double dy = details.localPosition.dy;

                                      _flavourX = ((dx / 200) * 2 - 1).clamp(
                                        -1.0,
                                        1.0,
                                      );
                                      _flavourY = -((dy / 200) * 2 - 1).clamp(
                                        -1.0,
                                        1.0,
                                      ); // Invert Y so up is positive
                                    });
                                  },
                                  onTapDown: (details) {
                                    setState(() {
                                      double dx = details.localPosition.dx;
                                      double dy = details.localPosition.dy;
                                      _flavourX = ((dx / 200) * 2 - 1).clamp(
                                        -1.0,
                                        1.0,
                                      );
                                      _flavourY = -((dy / 200) * 2 - 1).clamp(
                                        -1.0,
                                        1.0,
                                      );
                                    });
                                  },
                                  child: CustomPaint(
                                    painter: _FlavourGraphPainter(
                                      _flavourX,
                                      _flavourY,
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.onSurface,
                                      l10n.sour,
                                      l10n.bitter,
                                      l10n.strong,
                                      l10n.weak,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _getTroubleshootingTips().isNotEmpty
                                  ? Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.lightbulb,
                                                    size: 16,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'TROUBLESHOOTER',
                                                    style: TextStyle(
                                                      fontFamily: 'RobotoMono',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              ..._getTroubleshootingTips().map((
                                                tip,
                                              ) {
                                                final isHeader = tip.endsWith(
                                                  ':',
                                                );
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 4,
                                                      ),
                                                  child: Text(
                                                    tip,
                                                    style: TextStyle(
                                                      fontFamily: 'RobotoMono',
                                                      fontSize: isHeader
                                                          ? 12
                                                          : 11,
                                                      fontWeight: isHeader
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isHeader
                                                          ? Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                  alpha: 0.7,
                                                                ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveShot,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'SAVE SHOT',
                              style: TextStyle(
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
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.05),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildCompactInput(
    BuildContext context,
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  keyboardType ??
                  const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTroubleshootingTips() {
    final List<String> tips = [];
    const threshold = 0.3; // Sensitivity for suggestions

    if (_flavourX < -threshold) {
      // Sour
      tips.add('SOUR (Under-extracted):');
      tips.add('• Grind Finer');
      tips.add('• Increase Yield (ratio)');
      tips.add('• Increase Temperature');
    } else if (_flavourX > threshold) {
      // Bitter
      tips.add('BITTER (Over-extracted):');
      tips.add('• Grind Coarser');
      tips.add('• Decrease Yield (ratio)');
      tips.add('• Decrease Temperature');
    }

    if (_flavourY < -threshold) {
      // Weak
      tips.add(
        _flavourX.abs() > threshold ? '' : 'WEAK (Watery):',
      ); // Header if needed
      if (_flavourX.abs() >= threshold) tips.add('WEAK (Watery):');
      tips.add('• Increase Dose (in)');
      tips.add('• Grind Finer');
    } else if (_flavourY > threshold) {
      // Strong
      tips.add(_flavourX.abs() > threshold ? '' : 'STRONG (Overpowering):');
      if (_flavourX.abs() >= threshold) tips.add('STRONG (Overpowering):');
      tips.add('• Decrease Dose (in)');
      tips.add('• Grind Coarser');
    }

    return tips.where((t) => t.isNotEmpty).toList();
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final ms = (milliseconds % 1000) ~/ 100; // Get first digit of milliseconds
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}.${ms.toString()}';
  }
}

class _FlavourGraphPainter extends CustomPainter {
  final double x;
  final double y;
  final Color accentColor;
  final Color onSurface;
  final String sourLabel;
  final String bitterLabel;
  final String strongLabel;
  final String weakLabel;

  _FlavourGraphPainter(
    this.x,
    this.y,
    this.accentColor,
    this.onSurface,
    this.sourLabel,
    this.bitterLabel,
    this.strongLabel,
    this.weakLabel,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = onSurface.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Axes
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Labels
    final textStyle = TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 10,
      color: onSurface.withValues(alpha: 0.6),
    );
    _drawText(canvas, sourLabel, Offset(10, size.height / 2), textStyle);
    _drawText(
      canvas,
      bitterLabel,
      Offset(size.width - 30, size.height / 2),
      textStyle,
    );
    _drawText(canvas, strongLabel, Offset(size.width / 2, 10), textStyle);
    _drawText(
      canvas,
      weakLabel,
      Offset(size.width / 2, size.height - 20),
      textStyle,
    );

    // Point
    // Map -1..1 to 0..width
    final px = (x + 1) / 2 * size.width;
    final py = (-y + 1) / 2 * size.height; // Invert Y

    canvas.drawCircle(Offset(px, py), 8, Paint()..color = accentColor);
    canvas.drawCircle(
      Offset(px, py),
      12,
      Paint()..color = accentColor.withValues(alpha: 0.3),
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _FlavourGraphPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y;
  }
}
