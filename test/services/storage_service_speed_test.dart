import 'package:flutter_test/flutter_test.dart';
import 'package:match_sheet/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Clear all data before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('Speed Training Storage', () {
    test('saveSpeedTrainingSession saves session correctly', () async {
      final attempts = [
        {
          'attemptNumber': 1,
          'timeInMilliseconds': 12345,
          'metTarget': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'attemptNumber': 2,
          'timeInMilliseconds': 13456,
          'metTarget': false,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ];

      await StorageService.saveSpeedTrainingSession(
        playerName: 'John Doe',
        playerId: 'player_123',
        targetTime: 12.5,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: attempts,
      );

      // Verify it was saved
      final sessions = await StorageService.loadSpeedTrainingSessions();
      expect(sessions.length, 1);

      final session = sessions[0];
      expect(session['playerName'], 'John Doe');
      expect(session['playerId'], 'player_123');
      expect(session['targetTime'], 12.5);
      expect(session['targetTimeUnit'], 'seconds');
      expect(session['distance'], 100.0);
      expect(session['distanceUnit'], 'meters');
      expect(session['totalAttempts'], 2);
      expect(session['attempts'], attempts);
    });

    test('calculates statistics correctly', () async {
      final attempts = [
        {
          'attemptNumber': 1,
          'timeInMilliseconds': 10000, // 10 seconds
          'metTarget': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'attemptNumber': 2,
          'timeInMilliseconds': 12000, // 12 seconds
          'metTarget': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'attemptNumber': 3,
          'timeInMilliseconds': 15000, // 15 seconds
          'metTarget': false,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ];

      await StorageService.saveSpeedTrainingSession(
        playerName: 'Jane Smith',
        playerId: 'player_456',
        targetTime: 12.5,
        targetTimeUnit: 'seconds',
        distance: 50.0,
        distanceUnit: 'meters',
        attempts: attempts,
      );

      final sessions = await StorageService.loadSpeedTrainingSessions();
      final session = sessions[0];

      // Check statistics
      expect(session['bestTime'], 10000);
      expect(session['averageTime'], (10000 + 12000 + 15000) / 3);
      expect(session['successRate'], closeTo(0.666, 0.001)); // 2/3
    });

    test('loadSpeedTrainingSessions returns empty list when no sessions', () async {
      final sessions = await StorageService.loadSpeedTrainingSessions();
      expect(sessions, isEmpty);
    });

    test('loadSpeedTrainingSessions filters by playerId', () async {
      // Save sessions for two different players
      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player A',
        playerId: 'player_a',
        targetTime: 10.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player B',
        playerId: 'player_b',
        targetTime: 15.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player A Again',
        playerId: 'player_a',
        targetTime: 12.0,
        targetTimeUnit: 'seconds',
        distance: 50.0,
        distanceUnit: 'yards',
        attempts: [],
      );

      // Load all sessions
      final allSessions = await StorageService.loadSpeedTrainingSessions();
      expect(allSessions.length, 3);

      // Load only player_a sessions
      final playerASessions = await StorageService.loadSpeedTrainingSessions(playerId: 'player_a');
      expect(playerASessions.length, 2);
      expect(playerASessions.every((s) => s['playerId'] == 'player_a'), true);

      // Load only player_b sessions
      final playerBSessions = await StorageService.loadSpeedTrainingSessions(playerId: 'player_b');
      expect(playerBSessions.length, 1);
      expect(playerBSessions[0]['playerId'], 'player_b');
    });

    test('sessions are sorted by date, newest first', () async {
      // Save three sessions with delays to ensure different timestamps
      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player',
        playerId: 'player_1',
        targetTime: 10.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      await Future.delayed(Duration(milliseconds: 10));

      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player',
        playerId: 'player_1',
        targetTime: 11.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      await Future.delayed(Duration(milliseconds: 10));

      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player',
        playerId: 'player_1',
        targetTime: 12.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      final sessions = await StorageService.loadSpeedTrainingSessions();
      
      // Newest first (12.0 should be first)
      expect(sessions[0]['targetTime'], 12.0);
      expect(sessions[1]['targetTime'], 11.0);
      expect(sessions[2]['targetTime'], 10.0);
    });

    test('deleteSpeedTrainingSession removes correct session', () async {
      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player',
        playerId: 'player_1',
        targetTime: 10.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      // Small delay to ensure different sessionIds
      await Future.delayed(Duration(milliseconds: 50));

      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player',
        playerId: 'player_1',
        targetTime: 12.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      final sessionsBeforeDelete = await StorageService.loadSpeedTrainingSessions();
      expect(sessionsBeforeDelete.length, 2);

      // Delete first session (newest, since sorted newest first)
      final sessionIdToDelete = sessionsBeforeDelete[0]['sessionId'] as String;
      await StorageService.deleteSpeedTrainingSession(sessionIdToDelete);

      final sessionsAfterDelete = await StorageService.loadSpeedTrainingSessions();
      expect(sessionsAfterDelete.length, 1);
      expect(sessionsAfterDelete[0]['sessionId'], isNot(sessionIdToDelete));
    });

    test('getSpeedTrainingSession returns correct session', () async {
      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player',
        playerId: 'player_1',
        targetTime: 10.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      final sessions = await StorageService.loadSpeedTrainingSessions();
      final sessionId = sessions[0]['sessionId'] as String;

      final session = await StorageService.getSpeedTrainingSession(sessionId);
      
      expect(session, isNotNull);
      expect(session!['sessionId'], sessionId);
      expect(session['playerName'], 'Player');
    });

    test('getSpeedTrainingSession returns null for non-existent session', () async {
      final session = await StorageService.getSpeedTrainingSession('non_existent_id');
      expect(session, isNull);
    });

    test('handles empty attempts list correctly', () async {
      await StorageService.saveSpeedTrainingSession(
        playerName: 'Player',
        playerId: 'player_1',
        targetTime: 10.0,
        targetTimeUnit: 'seconds',
        distance: 100.0,
        distanceUnit: 'meters',
        attempts: [],
      );

      final sessions = await StorageService.loadSpeedTrainingSessions();
      final session = sessions[0];

      expect(session['totalAttempts'], 0);
      expect(session['bestTime'], 0);
      expect(session['averageTime'], 0.0);
      expect(session['successRate'], 0.0);
    });

    test('saves multiple sessions for same player', () async {
      for (int i = 0; i < 5; i++) {
        await StorageService.saveSpeedTrainingSession(
          playerName: 'Player',
          playerId: 'player_1',
          targetTime: 10.0 + i,
          targetTimeUnit: 'seconds',
          distance: 100.0,
          distanceUnit: 'meters',
          attempts: [],
        );
      }

      final sessions = await StorageService.loadSpeedTrainingSessions(playerId: 'player_1');
      expect(sessions.length, 5);
    });
  });
}
