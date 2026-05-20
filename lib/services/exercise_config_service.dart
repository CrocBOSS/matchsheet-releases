import '../services/storage_service.dart';

/// Service to manage exercise configurations centrally
/// All screens should use this to get exercise metadata
class ExerciseConfigService {
  static Map<String, ExerciseInfo> _exerciseCache = {};
  static bool _initialized = false;

  /// Initialize the exercise cache from storage
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      final exercises = await StorageService.loadStrengthExercises();
      _exerciseCache.clear();
      
      for (final exercise in exercises) {
        _exerciseCache[exercise['key'] as String] = ExerciseInfo(
          key: exercise['key'] as String,
          label: exercise['label'] as String,
          unit: exercise['unit'] as String? ?? 'reps',
          isPerLeg: exercise['isPerLeg'] as bool? ?? false,
        );
      }
      
      _initialized = true;
    } catch (e) {
      // Fallback to defaults if loading fails
      _initializeDefaults();
    }
  }

  /// Get exercise info by key
  static ExerciseInfo? getExercise(String exerciseKey) {
    return _exerciseCache[exerciseKey];
  }

  /// Get the display label for an exercise
  static String getExerciseLabel(String exerciseKey) {
    return _exerciseCache[exerciseKey]?.label ?? exerciseKey;
  }

  /// Get the unit for an exercise (e.g., "reps", "meters")
  static String getExerciseUnit(String exerciseKey) {
    return _exerciseCache[exerciseKey]?.unit ?? 'reps';
  }

  /// Check if exercise is per-leg
  static bool isPerLeg(String exerciseKey) {
    return _exerciseCache[exerciseKey]?.isPerLeg ?? false;
  }

  /// Clear the cache (call when exercises are updated in settings)
  static void clearCache() {
    _exerciseCache.clear();
    _initialized = false;
  }

  /// Initialize with default exercises
  static void _initializeDefaults() {
    _exerciseCache = {
      'pushUps': ExerciseInfo(
        key: 'pushUps',
        label: 'Push Ups',
        unit: 'reps',
        isPerLeg: false,
      ),
      'sitUps': ExerciseInfo(
        key: 'sitUps',
        label: 'Sit Ups',
        unit: 'reps',
        isPerLeg: false,
      ),
      'calfRises': ExerciseInfo(
        key: 'calfRises',
        label: 'Calf Rises',
        unit: 'reps',
        isPerLeg: true,
      ),
      'crabWalk': ExerciseInfo(
        key: 'crabWalk',
        label: 'Crab Walk',
        unit: 'meters',
        isPerLeg: false,
      ),
    };
    _initialized = true;
  }
}

class ExerciseInfo {
  final String key;
  final String label;
  final String unit;
  final bool isPerLeg;

  ExerciseInfo({
    required this.key,
    required this.label,
    required this.unit,
    required this.isPerLeg,
  });
}
