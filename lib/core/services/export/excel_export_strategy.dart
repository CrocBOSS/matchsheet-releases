import 'package:excel/excel.dart';
import 'export_strategy.dart';

/// Excel file export strategy
/// 
/// Exports data as Excel (.xlsx) files.
class ExcelExportStrategy implements ExportStrategy {
  @override
  String get fileExtension => 'xlsx';

  @override
  String get mimeType =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  @override
  Future<List<int>> export(dynamic data) async {
    if (data is Excel) {
      final bytes = data.encode();
      if (bytes == null) {
        throw Exception('Failed to encode Excel data');
      }
      return bytes;
    }
    throw ArgumentError('ExcelExportStrategy requires Excel data');
  }
}
