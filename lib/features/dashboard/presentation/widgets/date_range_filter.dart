import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;

class DateRangeFilter extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final VoidCallback onReset;

  const DateRangeFilter({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
    required this.onReset,
  });

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  String _selectedPreset = 'All Time';
  late final Map<String, Map<String, DateTime?>> _presets;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _presets = app_date_utils.DateUtils.getDatePresets();
    _updateSelectedPreset();
  }

  @override
  void didUpdateWidget(DateRangeFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate || oldWidget.endDate != widget.endDate) {
      _updateSelectedPreset();
      _isUpdating = false;
    }
  }

  void _updateSelectedPreset() {
    for (final entry in _presets.entries) {
      if (entry.value['start'] == widget.startDate && entry.value['end'] == widget.endDate) {
        _selectedPreset = entry.key;
        break;
      }
    }
  }

  void _selectPreset(String preset) {
    if (_isUpdating) return; // Prevent rapid changes
    
    setState(() {
      _selectedPreset = preset;
      _isUpdating = true;
    });
    
    final dates = _presets[preset]!;
    widget.onDateRangeChanged(dates['start'], dates['end']);
  }

  Future<void> _selectCustomDateRange() async {
    if (_isUpdating) return; // Prevent rapid changes
    
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: widget.startDate != null && widget.endDate != null
          ? DateTimeRange(start: widget.startDate!, end: widget.endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = 'Custom';
        _isUpdating = true;
      });
      widget.onDateRangeChanged(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tooltip(
                  message: 'Date Range Filter',
                  child: Semantics(
                    label: 'Date Range Filter',
                    child: const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Row(
                  children: [
                    if (_isUpdating) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Tooltip(
                      message: 'Reset all filters',
                      child: Semantics(
                        label: 'Reset all filters',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _isUpdating ? null : widget.onReset,
                          tooltip: 'Reset filters',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.keys.map((preset) {
                final isSelected = _selectedPreset == preset;
                return Tooltip(
                  message: 'Select $preset date range',
                  child: Semantics(
                    label: isSelected ? '$preset date range selected' : 'Select $preset date range',
                    button: true,
                    selected: isSelected,
                    child: FilterChip(
                      label: Text(preset),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected && !_isUpdating) {
                          _selectPreset(preset);
                        }
                      },
                      selectedColor: Theme.of(context).primaryColor.withAlpha((255 * 0.2).toInt()),
                      disabledColor: Colors.grey.withAlpha((255 * 0.3).toInt()),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Tooltip(
                message: 'Select a custom date range',
                child: Semantics(
                  label: 'Select a custom date range',
                  button: true,
                  child: OutlinedButton.icon(
                    onPressed: _isUpdating ? null : _selectCustomDateRange,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Custom Date Range'),
                  ),
                ),
              ),
            ),
            if (widget.startDate != null || widget.endDate != null) ...[
              const SizedBox(height: 12),
              Text(
                'Selected: ${app_date_utils.DateUtils.formatDateRange(widget.startDate, widget.endDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 