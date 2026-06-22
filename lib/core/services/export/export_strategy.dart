/// Strategy interface for different export formats
/// 
/// This interface allows for different export implementations
/// (TXT, Excel, PDF, etc.) using the Strategy pattern.
abstract class ExportStrategy {
  /// File extension for this export format (e.g., 'txt', 'xlsx')
  String get fileExtension;

  /// MIME type for this export format
  String get mimeType;

  /// Export data and return as bytes
  Future<List<int>> export(dynamic data);
}
