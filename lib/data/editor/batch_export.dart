import 'dart:io';

import 'package:flutter/material.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/file_manager/file_manager.dart';

class BatchExport {
  /// Exports all notes to individual PDF files in the documents directory.
  static Future<void> exportAllNotesToPdf(BuildContext context) async {
    final allFiles = await FileManager.getAllFiles(includeExtensions: true);
    final noteFiles = allFiles.where((file) =>
        file.endsWith('.sbn') || file.endsWith('.sbn2') || file.endsWith('.sba')).toList();

    if (noteFiles.isEmpty) {
      // No notes to export
      return;
    }

    for (final filePath in noteFiles) {
      final coreInfo = await EditorCoreInfo.loadFromFilePath(filePath);
      if (!context.mounted) break;

      final fileNameWithoutExtension = coreInfo.filePath.substring(
        coreInfo.filePath.lastIndexOf('/') + 1,
      );

      final pdfDoc = await EditorExporter.generatePdf(coreInfo, context);
      final pdfBytes = await pdfDoc.save();
      final pdfFile = FileManager.getFile('$fileNameWithoutExtension.pdf');
      await pdfFile.writeAsBytes(pdfBytes);
    }
  }
}