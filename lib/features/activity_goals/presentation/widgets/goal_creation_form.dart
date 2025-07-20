import 'package:flutter/material.dart';
import '../../data/models/activity_goal.dart';

class GoalCreationForm extends StatefulWidget {
  final ActivityGoal? initialGoal;
  final void Function(ActivityGoal goal) onSave;

  const GoalCreationForm({super.key, this.initialGoal, required this.onSave});

  @override
  State<GoalCreationForm> createState() => _GoalCreationFormState();
}

class _GoalCreationFormState extends State<GoalCreationForm> {
  final _formKey = GlobalKey<FormState>();
  late GoalType _goalType;
  String? _description;
  double? _targetValue;
  String? _unit;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final g = widget.initialGoal;
    _goalType = g?.goalType ?? GoalType.quantitative;
    _description = g?.description;
    _targetValue = g?.targetValue;
    _unit = g?.unit;
    _tags = List<String>.from(g?.tags ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Goal', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalType>(
                  value: _goalType,
                  decoration: const InputDecoration(labelText: 'Goal Type'),
                  items: GoalType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                  )).toList(),
                  onChanged: (val) => setState(() => _goalType = val!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (val) => _description = val,
                  validator: (val) => (val == null || val.isEmpty) ? 'Enter a description' : null,
                ),
                const SizedBox(height: 12),
                if (_goalType == GoalType.quantitative) ...[
                  TextFormField(
                    initialValue: _targetValue?.toString(),
                    decoration: const InputDecoration(labelText: 'Target Value'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _targetValue = double.tryParse(val),
                    validator: (val) {
                      final v = double.tryParse(val ?? '');
                      if (v == null || v <= 0) return 'Enter a valid target';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: ['calories', 'km', 'minutes', 'hours']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => _unit = val),
                    validator: (val) => (val == null || val.isEmpty) ? 'Select a unit' : null,
                  ),
                ],
                if (_goalType == GoalType.qualitative) ...[
                  TextFormField(
                    initialValue: _tags.join(', '),
                    decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                    onChanged: (val) => _tags = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                    validator: (val) => (val == null || val.isEmpty) ? 'Enter at least one tag' : null,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final goal = ActivityGoal(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              goalType: _goalType,
                              description: _description,
                              targetValue: _goalType == GoalType.quantitative ? _targetValue : null,
                              unit: _goalType == GoalType.quantitative ? _unit : null,
                              tags: _goalType == GoalType.qualitative ? _tags : null,
                              createdAt: DateTime.now(),
                            );
                            widget.onSave(goal);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Save Goal'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 