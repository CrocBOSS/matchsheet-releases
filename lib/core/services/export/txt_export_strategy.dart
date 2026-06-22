import 'export_strategy.dart';

/// Text file export strategy
/// 
/// Exports data as plain text (.txt) files.
class TxtExportStrategy implements ExportStrategy {
  @override
  String get fileExtension => 'txt';

  @override
  String get mimeType => 'text/plain';

  @override
  Future<List<int>> export(dynamic data) async {
    if (data is String) {
      return data.codeUnits;
    }
    throw ArgumentError('TxtExportStrategy requires String data');
  }
}
