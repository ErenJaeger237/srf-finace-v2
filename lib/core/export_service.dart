import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/models.dart';

class ExportService {
  static Future<void> exportToExcel({
    required List<Contribution> contributions,
    required List<Expense> expenses,
    required List<Cell> cells,
  }) async {
    var excel = Excel.createExcel();
    
    // 1. Contributions Sheet
    Sheet sheet1 = excel['Contributions'];
    sheet1.appendRow([TextCellValue('Member Name'), TextCellValue('Amount (FCFA)'), TextCellValue('Date'), TextCellValue('Status')]);
    for (var c in contributions) {
      sheet1.appendRow([TextCellValue(c.userName), DoubleCellValue(c.amount), TextCellValue(c.date.toString()), TextCellValue(c.isPaid ? 'PAID' : 'PENDING')]);
    }

    // 2. Expenses Sheet
    Sheet sheet2 = excel['Expenses'];
    sheet2.appendRow([TextCellValue('Title'), TextCellValue('Amount (FCFA)'), TextCellValue('Cell'), TextCellValue('Date'), TextCellValue('Performed By')]);
    for (var e in expenses) {
      sheet2.appendRow([TextCellValue(e.title), DoubleCellValue(e.amount), TextCellValue(e.cellName), TextCellValue(e.date.toString()), TextCellValue(e.performedBy)]);
    }

    // 3. Budgets Summary
    Sheet sheet3 = excel['Budget Summary'];
    sheet3.appendRow([TextCellValue('Cell Name'), TextCellValue('Budget'), TextCellValue('Spent'), TextCellValue('Remaining')]);
    for (var cell in cells) {
      sheet3.appendRow([TextCellValue(cell.name), DoubleCellValue(cell.budget), DoubleCellValue(cell.spent), DoubleCellValue(cell.remaining)]);
    }

    // Save and Share
    var fileBytes = excel.save();
    var directory = await getTemporaryDirectory();
    
    String fileName = "SRFM_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    File file = File('${directory.path}/$fileName')
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    await Share.shareXFiles([XFile(file.path)], text: 'SRFM Financial Report');
  }
}
