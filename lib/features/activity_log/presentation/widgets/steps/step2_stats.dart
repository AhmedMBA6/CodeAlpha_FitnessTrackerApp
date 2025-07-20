/// Step2Stats widget handles the second step of the activity log form: entering basic stats (duration, distance, calories).
import 'package:flutter/material.dart';
import '../../../logic/activity_log_form_cubit.dart';
import 'package:codealpha_fitness_tracker_app/core/constants/ui_constants.dart';

/// Widget for entering basic stats in the activity log form.
class Step2Stats extends StatefulWidget {
  final ActivityLogFormState state;
  final ActivityLogFormCubit cubit;
  const Step2Stats({required this.state, required this.cubit, super.key});
  @override
  State<Step2Stats> createState() => _Step2StatsState();
}

class _Step2StatsState extends State<Step2Stats> {
  late TextEditingController _durationController;
  late TextEditingController _distanceController;
  late TextEditingController _caloriesController;
  late FocusNode _durationFocusNode;
  late FocusNode _distanceFocusNode;
  late FocusNode _caloriesFocusNode;
  bool _realTime = false;
  String? _editingField;
  static const double walkingSpeedKmPerMin = 5.0 / 60.0; // 5 km/h
  static const double walkingCaloriesPerMin = 4.0;
  static const double runningSpeedKmPerMin = 10.0 / 60.0; // 10 km/h
  static const double runningCaloriesPerMin = 10.0;
  bool _isUpdatingFields = false;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(text: widget.state.duration?.toString() ?? '');
    _distanceController = TextEditingController(text: widget.state.distance?.toString() ?? '');
    _caloriesController = TextEditingController(text: widget.state.calories?.toString() ?? '');
    _durationFocusNode = FocusNode();
    _distanceFocusNode = FocusNode();
    _caloriesFocusNode = FocusNode();
    _realTime = widget.state.realTime;
    // No addListener or _onFieldFocusChange lines remain
  }

  @override
  void dispose() {
    _durationController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    _durationFocusNode.dispose();
    _distanceFocusNode.dispose();
    _caloriesFocusNode.dispose();
    super.dispose();
  }

  void _onFieldChanged(String field) {
    if (_isUpdatingFields) return;
    setState(() => _editingField = field);
    final selectedType = widget.state.selectedType;
    final isWalking = selectedType?.name == 'walk';
    final isRunning = selectedType?.name == 'run';
    double? duration = double.tryParse(_durationController.text);
    double? distance = double.tryParse(_distanceController.text);
    double? calories = double.tryParse(_caloriesController.text);
    // If the field being edited is cleared, clear all fields
    if ((field == 'duration' && _durationController.text.isEmpty) ||
        (field == 'distance' && _distanceController.text.isEmpty) ||
        (field == 'calories' && _caloriesController.text.isEmpty)) {
      _isUpdatingFields = true;
      _durationController.text = '';
      _distanceController.text = '';
      _caloriesController.text = '';
      setState(() => _editingField = null);
      _isUpdatingFields = false;
      widget.cubit.inputStats(
        duration: 0,
        distance: null,
        calories: 0,
        realTime: _realTime,
      );
      return;
    }
    // Auto-calculate for walking/running
    if ((isWalking || isRunning)) {
      double speed = isWalking ? walkingSpeedKmPerMin : runningSpeedKmPerMin;
      double calPerMin = isWalking ? walkingCaloriesPerMin : runningCaloriesPerMin;
      _isUpdatingFields = true;
      if (field == 'duration' && duration != null) {
        distance = duration * speed;
        calories = duration * calPerMin;
        _distanceController.text = distance.toStringAsFixed(2);
        _caloriesController.text = calories.toStringAsFixed(1);
      } else if (field == 'distance' && distance != null) {
        duration = distance / speed;
        calories = duration * calPerMin;
        _durationController.text = duration.toStringAsFixed(0);
        _caloriesController.text = calories.toStringAsFixed(1);
      } else if (field == 'calories' && calories != null) {
        duration = calories / calPerMin;
        distance = duration * speed;
        _durationController.text = duration.toStringAsFixed(0);
        _distanceController.text = distance.toStringAsFixed(2);
      }
      _isUpdatingFields = false;
      widget.cubit.inputStats(
        duration: duration?.toInt() ?? 0,
        distance: distance,
        calories: calories ?? 0,
        realTime: _realTime,
      );
      setState(() {});
      return;
    }
    // For other types or if not all values present, just update cubit
    widget.cubit.inputStats(
      duration: duration?.toInt() ?? 0,
      distance: distance,
      calories: calories ?? 0,
      realTime: _realTime,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = widget.state.selectedType;
    final isWalking = selectedType?.name == 'walk';
    final isRunning = selectedType?.name == 'run';
    final showAutoCalc = isWalking || isRunning;
    final readOnly = _editingField != null && showAutoCalc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAutoCalc)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Values are auto-calculated for ${isWalking ? 'walking' : 'running'} averages. Edit any field to recalculate.',
              style: TextStyle(color: Colors.deepPurple, fontSize: 12),
            ),
          ),
        TextField(
          controller: _durationController,
          decoration: const InputDecoration(labelText: 'Duration (minutes)'),
          keyboardType: TextInputType.number,
          focusNode: _durationFocusNode,
          readOnly: readOnly && _editingField != 'duration',
          onChanged: (_) => _onFieldChanged('duration'),
        ),
        const SizedBox(height: UIConstants.fieldSpacing),
        TextField(
          controller: _distanceController,
          decoration: const InputDecoration(labelText: 'Distance (km, optional)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusNode: _distanceFocusNode,
          readOnly: readOnly && _editingField != 'distance',
          onChanged: (_) => _onFieldChanged('distance'),
        ),
        const SizedBox(height: UIConstants.fieldSpacing),
        TextField(
          controller: _caloriesController,
          decoration: const InputDecoration(labelText: 'Calories'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusNode: _caloriesFocusNode,
          readOnly: readOnly && _editingField != 'calories',
          onChanged: (_) => _onFieldChanged('calories'),
        ),
        const SizedBox(height: UIConstants.fieldSpacing),
        Row(
          children: [
            Checkbox(
              value: _realTime,
              onChanged: (v) {
                setState(() => _realTime = v ?? false);
                // Update cubit on checkbox change
                widget.cubit.inputStats(
                  duration: double.tryParse(_durationController.text)?.toInt() ?? 0,
                  distance: double.tryParse(_distanceController.text),
                  calories: double.tryParse(_caloriesController.text) ?? 0,
                  realTime: _realTime,
                );
              },
            ),
            const Text('Real-time tracking'),
          ],
        ),
      ],
    );
  }
} 