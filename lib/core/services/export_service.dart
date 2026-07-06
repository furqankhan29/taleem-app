import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/logger.dart';
import 'package:taleem/data/models/export_log_model.dart';
import 'package:taleem/data/models/report_model.dart';

class ExportService extends GetxService {
  Future<ExportLogModel> exportToPdf({
    required String title,
    required Map<String, dynamic> data,
    required ReportType type,
  }) async {
    final id = Helpers.generateUniqueId();
    final log = ExportLogModel(
      id: id,
      reportTitle: title,
      format: ExportFormat.pdf,
      createdAt: DateTime.now(),
      filters: data,
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${_sanitizeFileName(title)}.pdf');
      await file.writeAsString(_generatePdfContent(title, data, type));
      Logger.success('PDF exported: ${file.path}');
      return log.copyWith(
        status: ExportStatus.completed,
        completedAt: DateTime.now(),
        filePath: file.path,
        fileUrl: file.path,
        fileSize: await file.length(),
      );
    } catch (e) {
      Logger.error('PDF export failed', e);
      return log.copyWith(
        status: ExportStatus.failed,
        completedAt: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  Future<ExportLogModel> exportToExcel({
    required String title,
    required List<Map<String, dynamic>> rows,
    required List<String> columns,
  }) async {
    final id = Helpers.generateUniqueId();
    final log = ExportLogModel(
      id: id,
      reportTitle: title,
      format: ExportFormat.excel,
      createdAt: DateTime.now(),
      filters: {'columns': columns, 'rowCount': rows.length},
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${_sanitizeFileName(title)}.csv');
      final buffer = StringBuffer();

      buffer.writeln(columns.join(','));
      for (final row in rows) {
        buffer.writeln(columns.map((c) {
          final val = row[c];
          if (val == null) return '';
          final str = val.toString();
          return str.contains(',') ? '"$str"' : str;
        }).join(','));
      }

      await file.writeAsString(buffer.toString());
      Logger.success('Excel/CSV exported: ${file.path}');
      return log.copyWith(
        status: ExportStatus.completed,
        completedAt: DateTime.now(),
        filePath: file.path,
        fileUrl: file.path,
        fileSize: await file.length(),
      );
    } catch (e) {
      Logger.error('Excel export failed', e);
      return log.copyWith(
        status: ExportStatus.failed,
        completedAt: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  Future<ExportLogModel> exportToCsv({
    required String title,
    required List<Map<String, dynamic>> rows,
    required List<String> columns,
  }) async {
    return exportToExcel(title: title, rows: rows, columns: columns);
  }

  Future<void> shareFile(String filePath, String title) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles([file], text: title);
    } catch (e) {
      Logger.error('Share failed', e);
      Helpers.showSnackbar(title: 'Error', message: 'Failed to share file', isError: true);
    }
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'[\s-]+'), '_');
  }

  String _generatePdfContent(String title, Map<String, dynamic> data, ReportType type) {
    final buffer = StringBuffer();
    buffer.writeln('=== $title ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Type: ${type.name}');
    buffer.writeln('');

    data.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    buffer.writeln('');
    buffer.writeln('=== Taleem AI Tuition Manager ===');
    return buffer.toString();
  }
}
