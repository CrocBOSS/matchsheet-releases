/// Generic repository interface for CRUD operations
/// 
/// This interface defines the contract for data storage operations.
/// Implementations can use SharedPreferences, SQLite, Firebase, etc.
abstract class StorageRepository<T> {
  /// Get all items from storage
  Future<List<T>> getAll();

  /// Get a specific item by ID
  Future<T?> getById(String id);

  /// Save a new item to storage
  Future<void> save(T item);

  /// Update an existing item
  Future<void> update(String id, T item);

  /// Delete an item by ID
  Future<void> delete(String id);

  /// Clear all items from storage
  Future<void> clear();
}
