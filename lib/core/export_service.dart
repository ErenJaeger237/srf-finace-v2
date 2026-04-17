import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/mock_repository.dart';

class ExportService {
  static Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    
    // 1. Contributions Sheet
    Sheet sheet1 = excel['Contributions'];
    sheet1.appendRow(['Member Name', 'Amount (FCFA)', 'Date', 'Status']);
    for (var c in MockRepository.recentContributions) {
      sheet1.appendRow([c.userName, c.amount, c.date.toString(), 'PAID']);
    }

    // 2. Expenses Sheet
    Sheet sheet2 = excel['Expenses'];
    sheet2.appendRow(['Title', 'Amount (FCFA)', 'Cell', 'Date', 'Performed By']);
    for (var e in MockRepository.recentExpenses) {
      sheet2.appendRow([e.title, e.amount, e.cellName, e.date.toString(), e.performedBy]);
    }

    // 3. Budgets Summary
    Sheet sheet3 = excel['Budget Summary'];
    sheet3.appendRow(['Cell Name', 'Budget', 'Spent', 'Remaining']);
    for (var cell in MockRepository.cells) {
      sheet3.appendRow([cell.name, cell.budget, cell.spent, cell.remaining]);
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
