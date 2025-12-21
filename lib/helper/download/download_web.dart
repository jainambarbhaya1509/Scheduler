import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart';

Future<void> downloadExcelFileWeb(String fileName) async {
  // 1. Load asset
  final byteData = await rootBundle.load('assets/template.xlsx');
  final bytes = byteData.buffer.asUint8List();

  // 2. Create Blob
  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );

  // 3. Create URL
  final url = html.Url.createObjectUrlFromBlob(blob);

  // 4. Trigger browser download
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';

  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();

  // 5. Cleanup
  html.Url.revokeObjectUrl(url);
}
