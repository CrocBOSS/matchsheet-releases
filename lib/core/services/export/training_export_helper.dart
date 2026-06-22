import 'package:excel/excel.dart';

/// Helper class for generating training export data
/// 
/// This class contains the business logic for formatting training data
/// for export, separated from the export mechanism itself.
class TrainingExportHelper {
  /// Generate training data export as text
  static String generateTrainingDataText({
    required String playerName,
    required int playerNumber,
    required String position,
    bool includeStrength = true,
    bool includeTechnical = true,
    List<Map<String, dynamic>>? strengthSessions,
    List<Map<String, dynamic>>? technicalSessions,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('=== TRAINING DATA EXPORT ===');
    buffer.writeln('Player: $playerName (#$playerNumber)');
    buffer.writeln('Position: $position');
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('');

    // Strength & Condition Section
    if (includeStrength &&
        strengthSessions != null &&
        strengthSessions.isNotEmpty) {
      buffer.writeln('=== STRENGTH & CONDITION SESSIONS ===');
      buffer.writeln('Total Sessions: ${strengthSessions.length}');
      buffer.writeln('');

      for (int i = 0; i < strengthSessions.length; i++) {
        final session = strengthSessions[i];
        final sessionName = session['name'] as String? ?? 'Session ${i + 1}';
        final timestamp = session['timestamp'] as String? ?? '';
        final structuredEntries =
            session['structuredEntries'] as List<dynamic>? ?? [];

        buffer.writeln('--- Session ${i + 1}: $sessionName ---');
        if (timestamp.isNotEmpty) {
          try {
            final dateTime = DateTime.parse(timestamp);
            buffer.writeln(
                'Date: ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}');
          } catch (e) {
            buffer.writeln('Date: $timestamp');
          }
        }
        buffer.writeln('');

        // Process each entry in the session
        for (final entryData in structuredEntries) {
          final entry = entryData as Map<String, dynamic>;
          final exercises = entry['exercises'] as List<dynamic>? ?? [];

          if (exercises.isEmpty) continue;

          buffer.writeln('Exercises:');
          for (final exerciseData in exercises) {
            final exercise = exerciseData as Map<String, dynamic>;
            final exerciseLabel =
                exercise['exerciseLabel'] as String? ?? 'Unknown';
            final isPerLeg = exercise['isPerLeg'] as bool? ?? false;
            final unit = exercise['unit'] as String? ?? 'reps';

            buffer.writeln('  • $exerciseLabel');

            if (isPerLeg) {
              final legs = exercise['legs'] as Map<String, dynamic>? ?? {};
              final leftSets = legs['left'] as List<dynamic>? ?? [];
              final rightSets = legs['right'] as List<dynamic>? ?? [];

              if (leftSets.isNotEmpty) {
                buffer.write('    Left: ');
                final leftValues = leftSets.map((s) {
                  final set = s as Map<String, dynamic>;
                  return '${set['reps']} $unit';
                }).join(', ');
                buffer.writeln(leftValues);
              }

              if (rightSets.isNotEmpty) {
                buffer.write('    Right: ');
                final rightValues = rightSets.map((s) {
                  final set = s as Map<String, dynamic>;
                  return '${set['reps']} $unit';
                }).join(', ');
                buffer.writeln(rightValues);
              }
            } else {
              final sets = exercise['sets'] as List<dynamic>? ?? [];
              if (sets.isNotEmpty) {
                buffer.write('    Sets: ');
                final setValues = sets.map((s) {
                  final set = s as Map<String, dynamic>;
                  return '${set['reps']} $unit';
                }).join(', ');
                buffer.writeln(setValues);
              }
            }
          }

          final notes = entry['notes'] as String? ?? '';
          if (notes.isNotEmpty) {
            buffer.writeln('  Notes: $notes');
          }
        }

        buffer.writeln('');
      }
    }

    // Technical Performance Section
    if (includeTechnical &&
        technicalSessions != null &&
        technicalSessions.isNotEmpty) {
      buffer.writeln('=== TECHNICAL PERFORMANCE SESSIONS ===');
      buffer.writeln('Total Sessions: ${technicalSessions.length}');
      buffer.writeln('');

      for (int i = 0; i < technicalSessions.length; i++) {
        final session = technicalSessions[i];
        final sessionName = session['name'] as String? ?? 'Session ${i + 1}';
        final timestamp = session['timestamp'] as String? ?? '';
        final skillLabel = session['skillLabel'] as String? ?? 'Unknown Skill';
        final successful = session['successful'] as int? ?? 0;
        final neutral = session['neutral'] as int? ?? 0;
        final fail = session['fail'] as int? ?? 0;
        final currentScore = session['currentScore'] as double? ?? 0.0;
        final targetScore = session['targetScore'] as double?;
        final totalReps = session['totalReps'] as int?;

        buffer.writeln('--- Session ${i + 1}: $sessionName ---');
        if (timestamp.isNotEmpty) {
          try {
            final dateTime = DateTime.parse(timestamp);
            buffer.writeln(
                'Date: ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}');
          } catch (e) {
            buffer.writeln('Date: $timestamp');
          }
        }
        buffer.writeln('Skill: $skillLabel');
        buffer.writeln('');

        buffer.writeln('Performance:');
        buffer.writeln('  ✓ Successful: $successful');
        buffer.writeln('  ⊙ Neutral: $neutral');
        buffer.writeln('  ✗ Failed: $fail');
        buffer.writeln('  Total Attempts: ${successful + neutral + fail}');
        buffer.writeln('');

        buffer.writeln('Score: ${currentScore.toStringAsFixed(1)}/10');
        if (targetScore != null) {
          buffer.writeln('Target Score: ${targetScore.toStringAsFixed(1)}/10');
        }
        if (totalReps != null) {
          buffer.writeln('Target Reps: $totalReps');
        }
        buffer.writeln('');
      }
    }

    // Summary
    buffer.writeln('=== SUMMARY ===');
    if (includeStrength && strengthSessions != null) {
      buffer.writeln(
          'Total Strength & Condition Sessions: ${strengthSessions.length}');
    }
    if (includeTechnical && technicalSessions != null) {
      buffer.writeln(
          'Total Technical Performance Sessions: ${technicalSessions.length}');
    }

    return buffer.toString();
  }

  /// Generate training data export as Excel file
  static Excel generateTrainingDataExcel({
    required String playerName,
    required int playerNumber,
    required String position,
    bool includeStrength = true,
    bool includeTechnical = true,
    List<Map<String, dynamic>>? strengthSessions,
    List<Map<String, dynamic>>? technicalSessions,
  }) {
    final excel = Excel.createExcel();

    // Create Summary Sheet
    final summarySheet = excel['Summary'];
    summarySheet.appendRow([TextCellValue('TRAINING DATA EXPORT')]);
    summarySheet.appendRow([
      TextCellValue('Player:'),
      TextCellValue('$playerName (#$playerNumber)'),
    ]);
    summarySheet.appendRow([
      TextCellValue('Position:'),
      TextCellValue(position),
    ]);
    summarySheet.appendRow([
      TextCellValue('Generated:'),
      TextCellValue(DateTime.now().toString()),
    ]);
    summarySheet.appendRow([TextCellValue('')]);

    if (includeStrength && strengthSessions != null) {
      summarySheet.appendRow([
        TextCellValue('Total Strength & Condition Sessions:'),
        IntCellValue(strengthSessions.length),
      ]);
    }
    if (includeTechnical && technicalSessions != null) {
      summarySheet.appendRow([
        TextCellValue('Total Technical Performance Sessions:'),
        IntCellValue(technicalSessions.length),
      ]);
    }

    // Strength & Condition Sheet
    if (includeStrength &&
        strengthSessions != null &&
        strengthSessions.isNotEmpty) {
      final strengthSheet = excel['Strength & Condition'];
      strengthSheet.appendRow([
        TextCellValue('Session'),
        TextCellValue('Date'),
        TextCellValue('Exercise'),
        TextCellValue('Leg'),
        TextCellValue('Set'),
        TextCellValue('Reps'),
        TextCellValue('Unit'),
        TextCellValue('Notes'),
      ]);

      for (int i = 0; i < strengthSessions.length; i++) {
        final session = strengthSessions[i];
        final sessionName = session['name'] as String? ?? 'Session ${i + 1}';
        final timestamp = session['timestamp'] as String? ?? '';
        String dateStr = '';
        if (timestamp.isNotEmpty) {
          try {
            final dateTime = DateTime.parse(timestamp);
            dateStr =
                '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
          } catch (e) {
            dateStr = timestamp;
          }
        }

        final structuredEntries =
            session['structuredEntries'] as List<dynamic>? ?? [];
        for (final entryData in structuredEntries) {
          final entry = entryData as Map<String, dynamic>;
          final exercises = entry['exercises'] as List<dynamic>? ?? [];
          final notes = entry['notes'] as String? ?? '';

          for (final exerciseData in exercises) {
            final exercise = exerciseData as Map<String, dynamic>;
            final exerciseLabel =
                exercise['exerciseLabel'] as String? ?? 'Unknown';
            final isPerLeg = exercise['isPerLeg'] as bool? ?? false;
            final unit = exercise['unit'] as String? ?? 'reps';

            if (isPerLeg) {
              final legs = exercise['legs'] as Map<String, dynamic>? ?? {};
              final leftSets = legs['left'] as List<dynamic>? ?? [];
              final rightSets = legs['right'] as List<dynamic>? ?? [];

              for (final setData in leftSets) {
                final set = setData as Map<String, dynamic>;
                strengthSheet.appendRow([
                  TextCellValue(sessionName),
                  TextCellValue(dateStr),
                  TextCellValue(exerciseLabel),
                  TextCellValue('Left'),
                  IntCellValue(set['set'] as int),
                  IntCellValue(set['reps'] as int),
                  TextCellValue(unit),
                  TextCellValue(notes),
                ]);
              }

              for (final setData in rightSets) {
                final set = setData as Map<String, dynamic>;
                strengthSheet.appendRow([
                  TextCellValue(sessionName),
                  TextCellValue(dateStr),
                  TextCellValue(exerciseLabel),
                  TextCellValue('Right'),
                  IntCellValue(set['set'] as int),
                  IntCellValue(set['reps'] as int),
                  TextCellValue(unit),
                  TextCellValue(notes),
                ]);
              }
            } else {
              final sets = exercise['sets'] as List<dynamic>? ?? [];
              for (final setData in sets) {
                final set = setData as Map<String, dynamic>;
                strengthSheet.appendRow([
                  TextCellValue(sessionName),
                  TextCellValue(dateStr),
                  TextCellValue(exerciseLabel),
                  TextCellValue('Both'),
                  IntCellValue(set['set'] as int),
                  IntCellValue(set['reps'] as int),
                  TextCellValue(unit),
                  TextCellValue(notes),
                ]);
              }
            }
          }
        }
      }
    }

    // Technical Performance Sheet
    if (includeTechnical &&
        technicalSessions != null &&
        technicalSessions.isNotEmpty) {
      final technicalSheet = excel['Technical Performance'];
      technicalSheet.appendRow([
        TextCellValue('Session'),
        TextCellValue('Date'),
        TextCellValue('Skill'),
        TextCellValue('Successful'),
        TextCellValue('Neutral'),
        TextCellValue('Failed'),
        TextCellValue('Total Attempts'),
        TextCellValue('Score'),
        TextCellValue('Target Score'),
        TextCellValue('Target Reps'),
      ]);

      for (int i = 0; i < technicalSessions.length; i++) {
        final session = technicalSessions[i];
        final sessionName = session['name'] as String? ?? 'Session ${i + 1}';
        final timestamp = session['timestamp'] as String? ?? '';
        String dateStr = '';
        if (timestamp.isNotEmpty) {
          try {
            final dateTime = DateTime.parse(timestamp);
            dateStr =
                '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
          } catch (e) {
            dateStr = timestamp;
          }
        }

        final skillLabel = session['skillLabel'] as String? ?? 'Unknown Skill';
        final successful = session['successful'] as int? ?? 0;
        final neutral = session['neutral'] as int? ?? 0;
        final fail = session['fail'] as int? ?? 0;
        final currentScore = session['currentScore'] as double? ?? 0.0;
        final targetScore = session['targetScore'] as double?;
        final totalReps = session['totalReps'] as int?;

        technicalSheet.appendRow([
          TextCellValue(sessionName),
          TextCellValue(dateStr),
          TextCellValue(skillLabel),
          IntCellValue(successful),
          IntCellValue(neutral),
          IntCellValue(fail),
          IntCellValue(successful + neutral + fail),
          DoubleCellValue(currentScore),
          targetScore != null
              ? DoubleCellValue(targetScore)
              : TextCellValue('-'),
          totalReps != null ? IntCellValue(totalReps) : TextCellValue('-'),
        ]);
      }
    }

    // Remove default Sheet1
    excel.delete('Sheet1');

    return excel;
  }
}
