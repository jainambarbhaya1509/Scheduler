import 'dart:developer';
import 'dart:js_interop';
import 'package:web/web.dart' as html;
import 'package:flutter/services.dart';

Future<void> downloadExcelFile(String url, String fileName) async {
  // Load template from assets
  final byteData = await rootBundle.load('assets/template.xlsx');
  final bytes = byteData.buffer.asUint8List();

  final blob = html.Blob([bytes] as JSArray<html.BlobPart>);
  final blobUrl = html.URL.createObjectURL(blob);

  html.HTMLAnchorElement()
    ..href = blobUrl
    ..download = fileName
    ..click();

  html.URL.revokeObjectURL(blobUrl);

  log("File downloaded via browser");
}
