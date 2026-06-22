import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration data returned from the Speed configuration dialog
class SpeedConfig {
  final double targetTime;
  final String targetTimeUnit;
  final double distance;
  final String distanceUnit;

  SpeedConfig({
    required this.targetTime,
    required this.targetTimeUnit,
    required this.distance,
    required this.distanceUnit,
  });
}

/// Shows a dialog to configure Speed training parameters
/// 
/// Returns a [SpeedConfig] if user confirms, or null if cancelled
Future<SpeedConfig?> showSpeedConfigDialog(BuildContext context) async {
  return showDialog<SpeedConfig>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _SpeedConfigDialog(),
  );
}

class _SpeedConfigDialog extends StatefulWidget {
  const _SpeedConfigDialog();

  @override
  State<_SpeedConfigDialog> createState() => _SpeedConfigDialogState();
}

class _SpeedConfigDialogState extends State<_SpeedConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetTimeController = TextEditingController();
  final _distanceController = TextEditingController();
  
  String _selectedTimeUnit = 'seconds';
  String _selectedDistanceUnit = 'meters';
  
  final List<String> _timeUnits = ['seconds', 'minutes'];
  final List<String> _distanceUnits = ['meters', 'yards'];

  @override
  void dispose() {
    _targetTimeController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      final targetTime = double.parse(_targetTimeController.text);
      final distance = double.parse(_distanceController.text);
      
      Navigator.of(context).pop(
        SpeedConfig(
          targetTime: targetTime,
          targetTimeUnit: _selectedTimeUnit,
          distance: distance,
          distanceUnit: _selectedDistanceUnit,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.speed, color: Colors.blue),
          const SizedBox(width: 12),
          const Text('Configure Speed Training'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Time Section
              Text(
                'Target Time',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Time input field
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _targetTimeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                      ],
                      decoration: const InputDecoration(
                        hintText: '12.5',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final time = double.tryParse(value);
                        if (time == null || time <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time unit dropdown
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      initialValue: _selectedTimeUnit,
                      items: _timeUnits.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTimeUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Distance Section
              Text(
                'Distance',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Distance input field
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        hintText: '100',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final distance = double.tryParse(value);
                        if (distance == null || distance <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Distance unit dropdown
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      initialValue: _selectedDistanceUnit,
                      items: _distanceUnits.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDistanceUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Info message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Unlimited attempts allowed',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Start Training'),
        ),
      ],
    );
  }
}
