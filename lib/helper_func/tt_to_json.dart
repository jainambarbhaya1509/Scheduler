// lib/helper_func/tt_to_json.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

/// Converts an Excel sheet into an HTML table string (handles merged cells).
String excelToHtml(Excel excel, String sheetName, Sheet sheet) {
  final mergedCellsMap = <Point<int>, Map<String, int>>{};
  final coveredCells = <Point<int>>{};

  // Use getMergedCells to fetch merge ranges
  final mergedRanges = excel.getMergedCells(sheetName);

  for (final merged in mergedRanges) {
    final range = merged.split(':');
    if (range.length != 2) continue;
    final start = CellIndex.indexByString(range[0]);
    final end = CellIndex.indexByString(range[1]);

    final minRow = start.rowIndex;
    final minCol = start.columnIndex;
    final maxRow = end.rowIndex;
    final maxCol = end.columnIndex;

    final rowspan = maxRow - minRow + 1;
    final colspan = maxCol - minCol + 1;

    mergedCellsMap[Point(minRow, minCol)] = {
      'rowspan': rowspan,
      'colspan': colspan,
    };

    for (int r = minRow; r <= maxRow; r++) {
      for (int c = minCol; c <= maxCol; c++) {
        if (!(r == minRow && c == minCol)) {
          coveredCells.add(Point(r, c));
        }
      }
    }
  }

  final html = StringBuffer()
    ..writeln('<table border="1" cellpadding="5" cellspacing="0">');

  for (int r = 0; r < sheet.rows.length; r++) {
    final row = sheet.rows[r];
    html.writeln('<tr>');
    for (int c = 0; c < row.length; c++) {
      final cell = row[c];
      final coord = Point(r, c);

      if (coveredCells.contains(coord)) continue;

      final cellValue = (cell?.value ?? '').toString().replaceAll('\n', '<br>');

      final attrs = <String>[];
      if (mergedCellsMap.containsKey(coord)) {
        final span = mergedCellsMap[coord]!;
        if (span['rowspan']! > 1) {
          attrs.add('rowspan="${span['rowspan']}"');
        }
        if (span['colspan']! > 1) {
          attrs.add('colspan="${span['colspan']}"');
        }
      }

      final td = attrs.isNotEmpty
          ? '<td ${attrs.join(' ')}>$cellValue</td>'
          : '<td>$cellValue</td>';
      html.writeln(td);
    }
    html.writeln('</tr>');
  }
  html.writeln('</table>');

  return html.toString();
}

/// Parse HTML produced from excelToHtml and extract empty slots.
/// Returns a Map with keys: department, class, slots -> list of {day, empty_slots}
Map<String, dynamic> extractEmptySlotsFromHtml(
    String html, String department, String className) {
  final document = parse(html);
  final table = document.querySelector('table');
  final rows = table?.querySelectorAll('tr') ?? [];

  final dayColumnsIndices = <int, String>{};
  final timeSlotsList = <String>[];

  if (rows.length > 8) {
    final headerCells = rows[8].querySelectorAll('td, th');
    for (int idx = 0; idx < headerCells.length; idx++) {
      final text = headerCells[idx].text.trim().toLowerCase();
      if ([
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
      ].contains(text)) {
        dayColumnsIndices[idx] = text;
      }
    }
  }

  final daySlotsFilled = {
    for (var day in dayColumnsIndices.values) day: <String>{},
  };

  final rowspanTracker = <int, Map<int, Element>>{};
  var currentRowNumber = 9;

  for (int r = 9; r < rows.length; r++) {
    final tr = rows[r];
    final cells = tr.querySelectorAll('td, th');
    if (cells.length < 2) continue;

    final timeSlotCell = cells.length > 1 ? cells[1] : null;
    final timeSlot = timeSlotCell?.text.trim().isNotEmpty == true
        ? timeSlotCell!.text.trim()
        : 'Slot $currentRowNumber';

    if (timeSlot.isNotEmpty && !timeSlotsList.contains(timeSlot)) {
      timeSlotsList.add(timeSlot);
    }

    final effectiveCells = <Element>[];
    int idx = 0;
    final iter = cells.iterator;

    while (idx <
        cells.length + (rowspanTracker[currentRowNumber]?.length ?? 0)) {
      if (rowspanTracker[currentRowNumber]?.containsKey(idx) == true) {
        effectiveCells.add(rowspanTracker[currentRowNumber]![idx]!);
        idx++;
        continue;
      }

      if (!iter.moveNext()) break;
      final cell = iter.current;

      final rowspan = int.tryParse(cell.attributes['rowspan'] ?? '1') ?? 1;
      final colspan = int.tryParse(cell.attributes['colspan'] ?? '1') ?? 1;

      if (rowspan > 1) {
        for (int i = 1; i < rowspan; i++) {
          rowspanTracker.putIfAbsent(currentRowNumber + i, () => {});
          rowspanTracker[currentRowNumber + i]![idx] = cell;
        }
      }

      for (int c = 0; c < colspan; c++) {
        effectiveCells.add(cell);
        idx++;
      }
    }

    for (int j = 0; j < effectiveCells.length; j++) {
      if (dayColumnsIndices.containsKey(j)) {
        final day = dayColumnsIndices[j]!;
        final text = effectiveCells[j].text.trim();
        if (text.isNotEmpty) {
          daySlotsFilled[day]!.add(timeSlot);
        }
      }
    }

    currentRowNumber++;
  }

  final result = {
    "department": department,
    'class': className,
    'slots': [],
  };

  for (var day in daySlotsFilled.keys) {
    final filled = daySlotsFilled[day]!;
    final emptySlots = timeSlotsList.where((ts) => !filled.contains(ts)).toList();

    (result['slots'] as List).add({'day': day, 'empty_slots': emptySlots});
  }

  return result;
}

/// Decode from a file path (mobile/desktop) and return JSON for all sheets.
Future<List<Map<String, dynamic>>> excelToJsonFile(
  String department,
  String filePath, {
  bool saveHtml = false,
  bool saveJson = true,
}) async {
  final bytes = await File(filePath).readAsBytes();
  return excelToJsonBytes(
    department,
    bytes,
    saveHtml: saveHtml,
    saveJson: saveJson,
    fileName: filePath.split(Platform.pathSeparator).last,
  );
}

/// Decode from bytes (web) and return JSON for all sheets.
/// `fileName` is optional and used only for naming saved files (if possible).
Future<List<Map<String, dynamic>>> excelToJsonBytes(
  String department,
  Uint8List bytes, {
  bool saveHtml = false,
  bool saveJson = false,
  String? fileName,
}) async {
  final excel = Excel.decodeBytes(bytes);

  final results = <Map<String, dynamic>>[];

  for (final sheetKey in excel.tables.keys) {
    final sheet = excel.tables[sheetKey]!;

    final html = excelToHtml(excel, sheetKey, sheet);
    final jsonResult = extractEmptySlotsFromHtml(html, department, sheetKey);

    results.add(jsonResult);

    if (saveHtml) {
      // Attempt to write if running on non-web platforms; ignore failures on web.
      try {
        final outName = '${sheetKey}_table_output.html';
        File(outName).writeAsStringSync(html);
      } catch (_) {}
    }
  }

  if (saveJson) {
    try {
      final outName = 'empty_slots_all_sheets.json';
      File(outName).writeAsStringSync(JsonEncoder.withIndent('  ').convert(results));
    } catch (_) {}
  }

  return results;
}
