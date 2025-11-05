import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:excel/excel.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

String excelToHtml(Excel excel, String sheetName, Sheet sheet) {
  final mergedCellsMap = <Point<int>, Map<String, int>>{};
  final coveredCells = <Point<int>>{};

  // Use getMergedCells to fetch merge ranges
  final mergedRanges = excel.getMergedCells(sheetName);

  for (final merged in mergedRanges) {
    final range = merged.split(':');
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

Map<String, dynamic> extractEmptySlotsFromHtml(String html) {
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
    "departmrent": "Information Technology",
    'class': '64',
    'slots': [],
  };

  for (var day in daySlotsFilled.keys) {
    final filled = daySlotsFilled[day]!;
    final emptySlots = timeSlotsList
        .where((ts) => !filled.contains(ts))
        .toList();

    // Add without casting
    (result['slots'] as List).add({'day': day, 'empty_slots': emptySlots});
  }

  return result;
}

Future<Map<String, dynamic>> excelToJson(
  String filePath,
  String? sheetName, {
  bool saveHtml = false,
  bool saveJson = true,
}) async {
  final bytes = File(filePath).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  final sheetKey = sheetName ?? excel.tables.keys.first;
  final sheet = excel.tables[sheetKey]!;

  final html = excelToHtml(excel, sheetKey, sheet);
  final jsonResult = extractEmptySlotsFromHtml(html);

  if (saveHtml) {
    File('table_output.html').writeAsStringSync(html);
  }
  if (saveJson) {
    File(
      'empty_slots.json',
    ).writeAsStringSync(JsonEncoder.withIndent('  ').convert(jsonResult));
  }

  return jsonResult;
}

void main() async {
  stdout.write('Excel file path (e.g. test.xlsx): ');
  final path = stdin.readLineSync()?.trim() ?? '';
  stdout.write('Sheet name (or press Enter for default sheet): ');
  final sheet = stdin.readLineSync()?.trim();

  final result = await excelToJson(
    path,
    (sheet != null && sheet.isNotEmpty) ? sheet : null,
    saveHtml: true,
    saveJson: true,
  );

  print('\nFinal Result JSON:');
  print(JsonEncoder.withIndent('  ').convert(result));
}
