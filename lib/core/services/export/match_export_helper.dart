import 'package:excel/excel.dart';
import '../../../models/match_entry.dart';
import '../../models/stat_type.dart';
import 'dart:convert';

/// Helper class for generating match export data
/// 
/// This class contains the business logic for formatting match data
/// for export, separated from the export mechanism itself.
class MatchExportHelper {
  /// Generate match sheet as text with header, JSON players, and summary for both halves
  static String generateMatchSheetText(
    List<Player> players,
    List<StatType> statTypes, {
    String teamName = 'Team A',
  }) {
    final buffer = StringBuffer();

    // Collect all stat keys (default + custom)
    final Set<String> allStatKeys = {};
    for (final stat in statTypes) {
      allStatKeys.add(stat.key);
    }
    // Add custom stat keys from players
    for (final player in players) {
      allStatKeys.addAll(player.customStats.keys);
      allStatKeys.addAll(player.secondHalfStats.keys);
    }

    // Header
    buffer.writeln('=== MATCH SHEET ===');
    buffer.writeln('Team Name: $teamName');
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('');

    // FULL MATCH SUMMARY - combines first and second half data
    buffer.writeln('=== FULL MATCH SUMMARY ===');
    buffer.writeln('Total Players: ${players.length}');
    for (final stat in statTypes) {
      final firstHalfTotal = _calculateFirstHalfStatTotal(players, stat.key);
      final secondHalfTotal = _calculateSecondHalfStatTotal(players, stat.key);
      final fullMatchTotal = firstHalfTotal + secondHalfTotal;
      buffer.writeln(
          'Total ${stat.label}: $fullMatchTotal (1st: $firstHalfTotal, 2nd: $secondHalfTotal)');
    }
    // Add custom stats totals
    for (final customKey in allStatKeys) {
      if (!statTypes.any((s) => s.key == customKey)) {
        final firstHalfTotal =
            _calculateFirstHalfCustomStatTotal(players, customKey);
        final secondHalfTotal =
            _calculateSecondHalfStatTotal(players, customKey);
        final fullMatchTotal = firstHalfTotal + secondHalfTotal;
        buffer.writeln(
            'Total ${customKey.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')}: $fullMatchTotal (1st: $firstHalfTotal, 2nd: $secondHalfTotal)');
      }
    }
    buffer.writeln('');

    // FIRST HALF SECTION
    buffer.writeln('=== FIRST HALF ===');
    buffer.writeln('PLAYER STATISTICS');

    final firstHalfPlayers = players.map((p) {
      final json = <String, dynamic>{
        'id': p.id,
        'number': p.number,
        'name': p.name,
        'position': p.position,
      };

      for (final stat in statTypes) {
        json[stat.key] = _getFirstHalfStatValue(p, stat.key);
      }

      for (final customKey in allStatKeys) {
        if (!statTypes.any((s) => s.key == customKey)) {
          json[customKey] = p.customStats[customKey] ?? 0;
        }
      }

      json['comments'] = p.comments;
      json['rating'] = p.rating > 0 ? '${p.rating}/10' : '-';

      return json;
    }).toList();

    const encoder = JsonEncoder.withIndent('  ');
    buffer.writeln(encoder.convert(firstHalfPlayers));
    buffer.writeln('');

    // FIRST HALF SUMMARY
    buffer.writeln('FIRST HALF SUMMARY');
    buffer.writeln('Total Players: ${players.length}');
    for (final stat in statTypes) {
      final total = _calculateFirstHalfStatTotal(players, stat.key);
      buffer.writeln('Total ${stat.label}: $total');
    }
    for (final customKey in allStatKeys) {
      if (!statTypes.any((s) => s.key == customKey)) {
        final total = _calculateFirstHalfCustomStatTotal(players, customKey);
        buffer.writeln(
            'Total ${customKey.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')}: $total');
      }
    }
    buffer.writeln('');

    // SECOND HALF SECTION
    buffer.writeln('=== SECOND HALF ===');
    buffer.writeln('PLAYER STATISTICS');

    final secondHalfPlayers = players.map((p) {
      final json = <String, dynamic>{
        'id': p.id,
        'number': p.number,
        'name': p.name,
        'position': p.position,
      };

      for (final stat in statTypes) {
        json[stat.key] = p.secondHalfStats[stat.key] ?? 0;
      }

      for (final customKey in allStatKeys) {
        if (!statTypes.any((s) => s.key == customKey)) {
          json[customKey] = p.secondHalfStats[customKey] ?? 0;
        }
      }

      json['comments'] = p.comments;
      json['rating'] = p.rating > 0 ? '${p.rating}/10' : '-';

      return json;
    }).toList();

    buffer.writeln(encoder.convert(secondHalfPlayers));
    buffer.writeln('');

    // SECOND HALF SUMMARY
    buffer.writeln('SECOND HALF SUMMARY');
    buffer.writeln('Total Players: ${players.length}');
    for (final stat in statTypes) {
      final total = _calculateSecondHalfStatTotal(players, stat.key);
      buffer.writeln('Total ${stat.label}: $total');
    }
    for (final customKey in allStatKeys) {
      if (!statTypes.any((s) => s.key == customKey)) {
        final total = _calculateSecondHalfStatTotal(players, customKey);
        buffer.writeln(
            'Total ${customKey.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')}: $total');
      }
    }
    buffer.writeln('');

    // FULL MATCH STATISTICS
    buffer.writeln('=== FULL MATCH STATISTICS ===');
    final fullMatchPlayers = players.map((p) {
      final json = <String, dynamic>{
        'id': p.id,
        'number': p.number,
        'name': p.name,
        'position': p.position,
      };

      for (final stat in statTypes) {
        final firstHalfValue = _getFirstHalfStatValue(p, stat.key);
        final secondHalfValue = p.secondHalfStats[stat.key] ?? 0;
        json[stat.key] = firstHalfValue + secondHalfValue;
      }

      for (final customKey in allStatKeys) {
        if (!statTypes.any((s) => s.key == customKey)) {
          final firstHalfValue = p.customStats[customKey] ?? 0;
          final secondHalfValue = p.secondHalfStats[customKey] ?? 0;
          json[customKey] = firstHalfValue + secondHalfValue;
        }
      }

      json['comments'] = p.comments;
      json['rating'] = p.rating > 0 ? '${p.rating}/10' : '-';

      return json;
    }).toList();

    buffer.writeln(encoder.convert(fullMatchPlayers));

    return buffer.toString();
  }

  /// Generate match sheet as Excel file
  static Excel generateMatchSheetExcel(
    List<Player> players,
    List<StatType> statTypes, {
    String teamName = 'Team A',
  }) {
    final excel = Excel.createExcel();

    // Collect all stat keys
    final Set<String> allStatKeys = {};
    for (final stat in statTypes) {
      allStatKeys.add(stat.key);
    }
    for (final player in players) {
      allStatKeys.addAll(player.customStats.keys);
      allStatKeys.addAll(player.secondHalfStats.keys);
    }

    // Create Summary Sheet
    final summarySheet = excel['Summary'];
    summarySheet.appendRow([
      TextCellValue('MATCH SHEET'),
    ]);
    summarySheet.appendRow([
      TextCellValue('Team Name:'),
      TextCellValue(teamName),
    ]);
    summarySheet.appendRow([
      TextCellValue('Generated:'),
      TextCellValue(DateTime.now().toString()),
    ]);
    summarySheet.appendRow([TextCellValue('')]);
    summarySheet.appendRow([
      TextCellValue('FULL MATCH SUMMARY'),
    ]);
    summarySheet.appendRow([
      TextCellValue('Total Players:'),
      IntCellValue(players.length),
    ]);

    for (final stat in statTypes) {
      final firstHalfTotal = _calculateFirstHalfStatTotal(players, stat.key);
      final secondHalfTotal = _calculateSecondHalfStatTotal(players, stat.key);
      final fullMatchTotal = firstHalfTotal + secondHalfTotal;
      summarySheet.appendRow([
        TextCellValue('Total ${stat.label}:'),
        IntCellValue(fullMatchTotal),
        TextCellValue('(1st: $firstHalfTotal, 2nd: $secondHalfTotal)'),
      ]);
    }

    // Create First Half Sheet
    final firstHalfSheet = excel['First Half'];
    final firstHalfHeaders = [
      TextCellValue('ID'),
      TextCellValue('Number'),
      TextCellValue('Name'),
      TextCellValue('Position'),
    ];
    for (final stat in statTypes) {
      firstHalfHeaders.add(TextCellValue(stat.label));
    }
    firstHalfHeaders.add(TextCellValue('Comments'));
    firstHalfHeaders.add(TextCellValue('Rating'));
    firstHalfSheet.appendRow(firstHalfHeaders);

    for (final player in players) {
      final row = [
        IntCellValue(player.id),
        IntCellValue(player.number),
        TextCellValue(player.name),
        TextCellValue(player.position),
      ];
      for (final stat in statTypes) {
        row.add(IntCellValue(_getFirstHalfStatValue(player, stat.key)));
      }
      row.add(TextCellValue(player.comments));
      row.add(TextCellValue(player.rating > 0 ? '${player.rating}/10' : '-'));
      firstHalfSheet.appendRow(row);
    }

    // Create Second Half Sheet
    final secondHalfSheet = excel['Second Half'];
    secondHalfSheet.appendRow(firstHalfHeaders);

    for (final player in players) {
      final row = [
        IntCellValue(player.id),
        IntCellValue(player.number),
        TextCellValue(player.name),
        TextCellValue(player.position),
      ];
      for (final stat in statTypes) {
        row.add(IntCellValue(player.secondHalfStats[stat.key] ?? 0));
      }
      row.add(TextCellValue(player.comments));
      row.add(TextCellValue(player.rating > 0 ? '${player.rating}/10' : '-'));
      secondHalfSheet.appendRow(row);
    }

    // Create Full Match Sheet
    final fullMatchSheet = excel['Full Match'];
    fullMatchSheet.appendRow(firstHalfHeaders);

    for (final player in players) {
      final row = [
        IntCellValue(player.id),
        IntCellValue(player.number),
        TextCellValue(player.name),
        TextCellValue(player.position),
      ];
      for (final stat in statTypes) {
        final firstHalfValue = _getFirstHalfStatValue(player, stat.key);
        final secondHalfValue = player.secondHalfStats[stat.key] ?? 0;
        row.add(IntCellValue(firstHalfValue + secondHalfValue));
      }
      row.add(TextCellValue(player.comments));
      row.add(TextCellValue(player.rating > 0 ? '${player.rating}/10' : '-'));
      fullMatchSheet.appendRow(row);
    }

    // Remove default Sheet1
    excel.delete('Sheet1');

    return excel;
  }

  // Helper methods
  static int _getFirstHalfStatValue(Player player, String statKey) {
    return player.customStats[statKey] ?? 0;
  }

  static int _calculateFirstHalfStatTotal(List<Player> players, String statKey) {
    int total = 0;
    for (final player in players) {
      total += player.customStats[statKey] ?? 0;
    }
    return total;
  }

  static int _calculateFirstHalfCustomStatTotal(
      List<Player> players, String statKey) {
    int total = 0;
    for (final player in players) {
      total += player.customStats[statKey] ?? 0;
    }
    return total;
  }

  static int _calculateSecondHalfStatTotal(
      List<Player> players, String statKey) {
    int total = 0;
    for (final player in players) {
      total += player.secondHalfStats[statKey] ?? 0;
    }
    return total;
  }
}
