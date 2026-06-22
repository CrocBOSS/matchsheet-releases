import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_repository.dart';

/// Implementation of StorageRepository using SharedPreferences
/// 
/// This class provides a generic way to store and retrieve data
/// using SharedPreferences as the underlying storage mechanism.
class LocalStorageRepository<T> implements StorageRepository<T> {
  final String storageKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  LocalStorageRepository({
    required this.storageKey,
    required this.fromJson,
    required this.toJson,
  });

  @override
  Future<List<T>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading from storage ($storageKey): $e');
      return [];
    }
  }

  @override
  Future<T?> getById(String id) async {
    final items = await getAll();
    try {
      return items.firstWhere(
        (item) => _getId(item) == id,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(T item) async {
    final items = await getAll();
    items.add(item);
    await _saveAll(items);
  }

  @override
  Future<void> update(String id, T item) async {
    final items = await getAll();
    final index = items.indexWhere((i) => _getId(i) == id);

    if (index >= 0) {
      items[index] = item;
      await _saveAll(items);
    }
  }

  @override
  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((item) => _getId(item) == id);
    await _saveAll(items);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }

  /// Save all items to storage
  Future<void> _saveAll(List<T> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => toJson(item)).toList();
      await prefs.setString(storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving to storage ($storageKey): $e');
      rethrow;
    }
  }

  /// Extract ID from item
  String _getId(T item) {
    final json = toJson(item);
    return json['id']?.toString() ?? '';
  }
}
