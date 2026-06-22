import 'package:flutter_test/flutter_test.dart';
import 'package:match_sheet/features/training/technical/models/speed_attempt.dart';

void main() {
  group('SpeedAttempt', () {
    final testTimestamp = DateTime(2026, 6, 22, 10, 30, 0);
    
    test('creates instance with all required fields', () {
      final attempt = SpeedAttempt(
        attemptNumber: 1,
        timeInMilliseconds: 12345,
        metTarget: true,
        timestamp: testTimestamp,
      );

      expect(attempt.attemptNumber, 1);
      expect(attempt.timeInMilliseconds, 12345);
      expect(attempt.metTarget, true);
      expect(attempt.timestamp, testTimestamp);
    });

    group('formattedTime', () {
      test('formats short time correctly (< 1 minute)', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12345, // 12.345 seconds
          metTarget: true,
          timestamp: testTimestamp,
        );

        expect(attempt.formattedTime, '00:12.345');
      });

      test('formats time with full minutes', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 125678, // 2:05.678
          metTarget: true,
          timestamp: testTimestamp,
        );

        expect(attempt.formattedTime, '02:05.678');
      });

      test('formats zero time', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 0,
          metTarget: false,
          timestamp: testTimestamp,
        );

        expect(attempt.formattedTime, '00:00.000');
      });

      test('formats time at exactly 1 minute', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 60000, // exactly 1 minute
          metTarget: true,
          timestamp: testTimestamp,
        );

        expect(attempt.formattedTime, '01:00.000');
      });

      test('formats time with only milliseconds', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 567, // 0.567 seconds
          metTarget: true,
          timestamp: testTimestamp,
        );

        expect(attempt.formattedTime, '00:00.567');
      });

      test('formats long time (> 10 minutes)', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 725890, // 12:05.890
          metTarget: false,
          timestamp: testTimestamp,
        );

        expect(attempt.formattedTime, '12:05.890');
      });
    });

    group('getDifferenceFromTarget', () {
      test('returns positive difference when over target', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 13000, // 13 seconds
          metTarget: false,
          timestamp: testTimestamp,
        );

        final diff = attempt.getDifferenceFromTarget(12000); // target: 12 seconds
        expect(diff, '+1.000s');
      });

      test('returns negative difference when under target', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 11500, // 11.5 seconds
          metTarget: true,
          timestamp: testTimestamp,
        );

        final diff = attempt.getDifferenceFromTarget(12000); // target: 12 seconds
        expect(diff, '-0.500s');
      });

      test('returns zero difference when exactly at target', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12000,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final diff = attempt.getDifferenceFromTarget(12000);
        expect(diff, '0.000s');
      });

      test('formats millisecond precision correctly', () {
        final attempt = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12234,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final diff = attempt.getDifferenceFromTarget(12500);
        expect(diff, '-0.266s');
      });
    });

    group('toJson and fromJson', () {
      test('serializes to JSON correctly', () {
        final attempt = SpeedAttempt(
          attemptNumber: 3,
          timeInMilliseconds: 15678,
          metTarget: false,
          timestamp: testTimestamp,
        );

        final json = attempt.toJson();

        expect(json['attemptNumber'], 3);
        expect(json['timeInMilliseconds'], 15678);
        expect(json['metTarget'], false);
        expect(json['timestamp'], testTimestamp.toIso8601String());
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'attemptNumber': 2,
          'timeInMilliseconds': 11234,
          'metTarget': true,
          'timestamp': testTimestamp.toIso8601String(),
        };

        final attempt = SpeedAttempt.fromJson(json);

        expect(attempt.attemptNumber, 2);
        expect(attempt.timeInMilliseconds, 11234);
        expect(attempt.metTarget, true);
        expect(attempt.timestamp, testTimestamp);
      });

      test('round-trip serialization preserves data', () {
        final original = SpeedAttempt(
          attemptNumber: 5,
          timeInMilliseconds: 98765,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final json = original.toJson();
        final restored = SpeedAttempt.fromJson(json);

        expect(restored.attemptNumber, original.attemptNumber);
        expect(restored.timeInMilliseconds, original.timeInMilliseconds);
        expect(restored.metTarget, original.metTarget);
        expect(restored.timestamp, original.timestamp);
      });
    });

    group('copyWith', () {
      test('creates copy with updated attemptNumber', () {
        final original = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12000,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final copy = original.copyWith(attemptNumber: 2);

        expect(copy.attemptNumber, 2);
        expect(copy.timeInMilliseconds, original.timeInMilliseconds);
        expect(copy.metTarget, original.metTarget);
        expect(copy.timestamp, original.timestamp);
      });

      test('creates copy with no changes when no parameters provided', () {
        final original = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12000,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final copy = original.copyWith();

        expect(copy.attemptNumber, original.attemptNumber);
        expect(copy.timeInMilliseconds, original.timeInMilliseconds);
        expect(copy.metTarget, original.metTarget);
        expect(copy.timestamp, original.timestamp);
      });

      test('creates copy with multiple updated fields', () {
        final original = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12000,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final newTimestamp = DateTime(2026, 6, 23);
        final copy = original.copyWith(
          timeInMilliseconds: 15000,
          metTarget: false,
          timestamp: newTimestamp,
        );

        expect(copy.attemptNumber, original.attemptNumber);
        expect(copy.timeInMilliseconds, 15000);
        expect(copy.metTarget, false);
        expect(copy.timestamp, newTimestamp);
      });
    });

    group('equality and hashCode', () {
      test('equal attempts have same hashCode', () {
        final attempt1 = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12000,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final attempt2 = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12000,
          metTarget: true,
          timestamp: testTimestamp,
        );

        expect(attempt1, equals(attempt2));
        expect(attempt1.hashCode, equals(attempt2.hashCode));
      });

      test('different attempts are not equal', () {
        final attempt1 = SpeedAttempt(
          attemptNumber: 1,
          timeInMilliseconds: 12000,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final attempt2 = SpeedAttempt(
          attemptNumber: 2,
          timeInMilliseconds: 12000,
          metTarget: true,
          timestamp: testTimestamp,
        );

        expect(attempt1, isNot(equals(attempt2)));
      });
    });

    group('toString', () {
      test('returns readable string representation', () {
        final attempt = SpeedAttempt(
          attemptNumber: 3,
          timeInMilliseconds: 12345,
          metTarget: true,
          timestamp: testTimestamp,
        );

        final string = attempt.toString();

        expect(string, contains('#3'));
        expect(string, contains('00:12.345'));
        expect(string, contains('true'));
      });
    });
  });
}
