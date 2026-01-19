import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'localization_helper.dart';

class PdfHelper {
  static Future<void> generateTransactionHistoryPdf(
    List<Map<String, dynamic>> transactions,
  ) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Transaction History',
                    style: pw.TextStyle(font: fontBold, fontSize: 24),
                  ),
                  pw.Text(
                    DateFormat('dd MMM yyyy', 'en_US').format(DateTime.now()),
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Date/Time',
                        style: pw.TextStyle(font: fontBold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Description',
                        style: pw.TextStyle(font: fontBold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Amount',
                        style: pw.TextStyle(font: fontBold),
                      ),
                    ),
                  ],
                ),
                ...transactions.map((tx) {
                  // Ensure date is in English
                  String englishTime = 'Just now';
                  if (tx['date'] != null) {
                    try {
                      final date = DateTime.parse(tx['date']);
                      englishTime = DateFormat(
                        'dd MMM yyyy, hh:mm a',
                        'en_US',
                      ).format(date);
                    } catch (_) {
                      englishTime = LocalizationHelper.convertBengaliToEnglish(
                        tx['time'] ?? 'Just now',
                      );
                    }
                  }

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          englishTime,
                          style: pw.TextStyle(font: font),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              LocalizationHelper.getEnglishTransactionTitle(tx),
                              style: pw.TextStyle(font: fontBold),
                            ),
                            pw.Text(
                              LocalizationHelper.getEnglishTransactionSubtitle(
                                tx,
                              ),
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          LocalizationHelper.convertBengaliToEnglish(
                            tx['amount'] ?? '0',
                          ),
                          style: pw.TextStyle(
                            font: fontBold,
                            color: tx['isCredit'] == true
                                ? PdfColors.green
                                : PdfColors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Transaction_History.pdf',
    );
  }

  static Future<void> generateInvoicePdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 32,
                          color: PdfColors.blueGrey800,
                        ),
                      ),
                      pw.Text(
                        'OmiBay Partner Network',
                        style: pw.TextStyle(font: font, color: PdfColors.grey),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Transaction ID: ${data['id'] ?? 'N/A'}',
                        style: pw.TextStyle(font: fontBold),
                      ),
                      pw.Text(
                        'Date: ${data['date'] ?? 'N/A'}',
                        style: pw.TextStyle(font: font),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Text(
                'Bill To:',
                style: pw.TextStyle(font: fontBold, color: PdfColors.grey),
              ),
              pw.Text(
                'Partner Name',
                style: pw.TextStyle(font: fontBold, fontSize: 18),
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey200),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(font: fontBold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text(
                          'Amount',
                          style: pw.TextStyle(font: fontBold),
                        ),
                      ),
                    ],
                  ),
                  ...(data['breakdown'] as List<Map<String, String>>).map((
                    item,
                  ) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(
                            item['label'] ?? '',
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(
                            item['value'] ?? '',
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Amount: ',
                    style: pw.TextStyle(font: fontBold, fontSize: 18),
                  ),
                  pw.Text(
                    data['total'] ?? '0',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 18,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.Center(
                child: pw.Text(
                  'This is a computer generated invoice.',
                  style: pw.TextStyle(font: font, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${data['id'] ?? 'txn'}.pdf',
    );
  }
}
