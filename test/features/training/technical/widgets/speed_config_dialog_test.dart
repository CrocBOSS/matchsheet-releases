import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:match_sheet/features/training/technical/widgets/speed_config_dialog.dart';

void main() {
  group('SpeedConfigDialog', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showSpeedConfigDialog(context),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Configure Speed Training'), findsOneWidget);
      expect(find.byIcon(Icons.speed), findsOneWidget);

      // Verify target time section
      expect(find.text('Target Time'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // time and distance

      // Verify distance section
      expect(find.text('Distance'), findsOneWidget);

      // Verify dropdowns
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));

      // Verify info message
      expect(find.text('Unlimited attempts allowed'), findsOneWidget);

      // Verify buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Start Training'), findsOneWidget);
    });

    testWidgets('shows validation error when target time is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showSpeedConfigDialog(context),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to submit without entering target time
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Required'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows validation error when distance is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showSpeedConfigDialog(context),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter only target time
      await tester.enterText(find.byType(TextFormField).first, '12.5');
      
      // Try to submit without entering distance
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should show validation error for distance
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('shows validation error when target time is zero', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showSpeedConfigDialog(context),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter zero as target time
      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.enterText(find.byType(TextFormField).last, '100');
      
      // Try to submit
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Must be > 0'), findsOneWidget);
    });

    testWidgets('shows validation error when distance is zero', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showSpeedConfigDialog(context),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter valid time but zero distance
      await tester.enterText(find.byType(TextFormField).first, '12.5');
      await tester.enterText(find.byType(TextFormField).last, '0');
      
      // Try to submit
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Must be > 0'), findsOneWidget);
    });

    testWidgets('returns null when Cancel is pressed', (WidgetTester tester) async {
      SpeedConfig? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showSpeedConfigDialog(context);
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Press Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should return null
      expect(result, isNull);
    });

    testWidgets('returns SpeedConfig with correct values when confirmed', (WidgetTester tester) async {
      SpeedConfig? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showSpeedConfigDialog(context);
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter valid values
      await tester.enterText(find.byType(TextFormField).first, '12.5');
      await tester.enterText(find.byType(TextFormField).last, '100');

      // Press Start Training
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should return valid config
      expect(result, isNotNull);
      expect(result!.targetTime, 12.5);
      expect(result!.targetTimeUnit, 'seconds');
      expect(result!.distance, 100.0);
      expect(result!.distanceUnit, 'meters');
    });

    testWidgets('allows changing time unit to minutes', (WidgetTester tester) async {
      SpeedConfig? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showSpeedConfigDialog(context);
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find time unit dropdown - it's the first dropdown
      final timeUnitDropdown = find.byType(DropdownButtonFormField<String>).first;
      
      // Tap to open dropdown
      await tester.tap(timeUnitDropdown);
      await tester.pumpAndSettle();

      // Select minutes
      await tester.tap(find.text('minutes').last);
      await tester.pumpAndSettle();

      // Enter valid values
      await tester.enterText(find.byType(TextFormField).first, '2.5');
      await tester.enterText(find.byType(TextFormField).last, '400');

      // Press Start Training
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should return config with minutes
      expect(result, isNotNull);
      expect(result!.targetTime, 2.5);
      expect(result!.targetTimeUnit, 'minutes');
    });

    testWidgets('allows changing distance unit to yards', (WidgetTester tester) async {
      SpeedConfig? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showSpeedConfigDialog(context);
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find distance unit dropdown - it's the second dropdown
      final distanceUnitDropdown = find.byType(DropdownButtonFormField<String>).last;
      
      // Tap to open dropdown
      await tester.tap(distanceUnitDropdown);
      await tester.pumpAndSettle();

      // Select yards
      await tester.tap(find.text('yards').last);
      await tester.pumpAndSettle();

      // Enter valid values
      await tester.enterText(find.byType(TextFormField).first, '12.5');
      await tester.enterText(find.byType(TextFormField).last, '110');

      // Press Start Training
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should return config with yards
      expect(result, isNotNull);
      expect(result!.distance, 110.0);
      expect(result!.distanceUnit, 'yards');
    });

    testWidgets('accepts decimal values for target time', (WidgetTester tester) async {
      SpeedConfig? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showSpeedConfigDialog(context);
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter decimal values
      await tester.enterText(find.byType(TextFormField).first, '12.543');
      await tester.enterText(find.byType(TextFormField).last, '100.5');

      // Press Start Training
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should accept decimal values
      expect(result, isNotNull);
      expect(result!.targetTime, 12.543);
      expect(result!.distance, 100.5);
    });

    testWidgets('has correct default values', (WidgetTester tester) async {
      SpeedConfig? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showSpeedConfigDialog(context);
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Just enter values without changing dropdowns
      await tester.enterText(find.byType(TextFormField).first, '10');
      await tester.enterText(find.byType(TextFormField).last, '100');

      // Press Start Training
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should have default units (seconds and meters)
      expect(result, isNotNull);
      expect(result!.targetTimeUnit, 'seconds');
      expect(result!.distanceUnit, 'meters');
    });

    testWidgets('dialog is not dismissible by tapping outside', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showSpeedConfigDialog(context),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to tap outside the dialog (tap on barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be visible
      expect(find.text('Configure Speed Training'), findsOneWidget);
    });

    testWidgets('handles large time values correctly', (WidgetTester tester) async {
      SpeedConfig? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showSpeedConfigDialog(context);
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter large values
      await tester.enterText(find.byType(TextFormField).first, '999.999');
      await tester.enterText(find.byType(TextFormField).last, '5000');

      // Press Start Training
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should handle large values
      expect(result, isNotNull);
      expect(result!.targetTime, 999.999);
      expect(result!.distance, 5000.0);
    });

    testWidgets('handles very small decimal values correctly', (WidgetTester tester) async {
      SpeedConfig? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showSpeedConfigDialog(context);
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter very small values
      await tester.enterText(find.byType(TextFormField).first, '0.001');
      await tester.enterText(find.byType(TextFormField).last, '0.5');

      // Press Start Training
      await tester.tap(find.text('Start Training'));
      await tester.pumpAndSettle();

      // Should handle small values
      expect(result, isNotNull);
      expect(result!.targetTime, 0.001);
      expect(result!.distance, 0.5);
    });
  });

  group('SpeedConfig', () {
    test('creates instance with correct values', () {
      final config = SpeedConfig(
        targetTime: 12.5,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
      );

      expect(config.targetTime, 12.5);
      expect(config.targetTimeUnit, 'seconds');
      expect(config.distance, 100.0);
      expect(config.distanceUnit, 'meters');
    });

    test('allows minutes as time unit', () {
      final config = SpeedConfig(
        targetTime: 2.5,
        targetTimeUnit: 'minutes',
        distance: 400.0,
        distanceUnit: 'meters',
      );

      expect(config.targetTimeUnit, 'minutes');
    });

    test('allows yards as distance unit', () {
      final config = SpeedConfig(
        targetTime: 12.5,
        targetTimeUnit: 'seconds',
        distance: 110.0,
        distanceUnit: 'yards',
      );

      expect(config.distanceUnit, 'yards');
    });
  });
}
