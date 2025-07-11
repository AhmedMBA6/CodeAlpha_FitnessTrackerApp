import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/activity_log_cubit.dart';
import '../../data/models/activity_log_model.dart';

class ActivityLogForm extends StatefulWidget {
  final ActivityLogModel? initialLog;
  final void Function()? onSaved;
  const ActivityLogForm({super.key, this.initialLog, this.onSaved});

  @override
  State<ActivityLogForm> createState() => _ActivityLogFormState();
}

class _ActivityLogFormState extends State<ActivityLogForm> {
  final _formKey = GlobalKey<FormState>();
  final _activityTypeCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialLog != null) {
      _activityTypeCtrl.text = widget.initialLog!.activityType;
      _durationCtrl.text = widget.initialLog!.duration.toString();
      _caloriesCtrl.text = widget.initialLog!.calories.toString();
      _selectedDate = widget.initialLog!.date;
      _dateCtrl.text = _selectedDate!.toIso8601String().split('T').first;
      if (widget.initialLog!.heartRate != null) {
        _heartRateCtrl.text = widget.initialLog!.heartRate.toString();
      }
      if (widget.initialLog!.distance != null) {
        _distanceCtrl.text = widget.initialLog!.distance.toString();
      }
    }
  }

  @override
  void dispose() {
    _activityTypeCtrl.dispose();
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    _dateCtrl.dispose();
    _heartRateCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final log = ActivityLogModel(
        id: widget.initialLog?.id,
        activityType: _activityTypeCtrl.text.trim(),
        duration: int.parse(_durationCtrl.text.trim()),
        calories: double.parse(_caloriesCtrl.text.trim()),
        date: _selectedDate!,
        heartRate: _heartRateCtrl.text.isNotEmpty ? int.tryParse(_heartRateCtrl.text.trim()) : null,
        distance: _distanceCtrl.text.isNotEmpty ? double.tryParse(_distanceCtrl.text.trim()) : null,
      );
      final cubit = context.read<ActivityLogCubit>();
      if (widget.initialLog == null) {
        cubit.addActivity(log);
      } else {
        cubit.updateActivity(log);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityLogCubit, ActivityLogState>(
      listener: (context, state) {
        if (state is ActivityLogSuccess) {
          if (widget.onSaved != null) widget.onSaved!();
        } else if (state is ActivityLogError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextFormField(
              controller: _activityTypeCtrl,
              decoration: const InputDecoration(labelText: 'Activity Type'),
              validator: (val) => val == null || val.isEmpty ? 'Enter activity type' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (min)'),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter duration';
                final d = int.tryParse(val);
                return (d == null || d <= 0) ? 'Invalid duration' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caloriesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories Burned'),
              validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid calories' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dateCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date'),
              onTap: () => _pickDate(context),
              validator: (val) => val == null || val.isEmpty ? 'Pick a date' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _heartRateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Heart Rate (optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _distanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Distance (km, optional)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.initialLog == null ? 'Add Activity' : 'Update Activity'),
            ),
          ],
        ),
      ),
    );
  }
} 