import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:saber/data/editor/editor_core_info.dart';

import 'package:saber/data/editor/editor_exporter.dart';

import 'package:saber/data/file_manager/file_manager.dart';

import 'package:saber/data/flavor_config.dart';

void main(List<String> args) async {

  if (args.length != 2) {

    print('Usage: dart run cli_export.dart <input_folder> <output_folder>');

    exit(1);

  }

  final inputDirPath = args[0];

  final outputDirPath = args[1];

  final inputDir = Directory(inputDirPath);

  final outputDir = Directory(outputDirPath);

  if (!inputDir.existsSync()) {

    print('Input folder does not exist: $inputDirPath');

    exit(1);

  }

  outputDir.createSync(recursive: true);

  // Initialize

  FlavorConfig.setupFromEnvironment();

  FileManager.shouldUseRawFilePath = true;

  FileManager.documentsDirectory = '';

  await FileManager.init(documentsDirectory: '');

  final files = inputDir.listSync().whereType<File>().where((f) => f.path.endsWith('.sbn') || f.path.endsWith('.sbn2') || f.path.endsWith('.sba'));

  for (final file in files) {

    print('Processing ${file.path}');

    try {

      final coreInfo = await EditorCoreInfo.loadFromFilePath(file.path);

      final pdf = await EditorExporter.generatePdf(coreInfo, null);

      final bytes = await pdf.save();

      final outputFileName = '${p.basenameWithoutExtension(file.path)}.pdf';

      final outputFile = File(p.join(outputDir.path, outputFileName));

      await outputFile.writeAsBytes(bytes);

      print('Exported to ${outputFile.path}');

    } catch (e) {

      print('Error processing ${file.path}: $e');

    }

  }

  print('Done');

}