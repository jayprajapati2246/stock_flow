import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';

class PdfDowload {
  static Future<void> generateInvoicePdf(SalesController controller) async {
    try {
      final pdf = pw.Document();
      final formatter = DateFormat('dd MMMM, yyyy');

      // ================= INVOICE NUMBER =================
      final prefs = await SharedPreferences.getInstance();
      int lastInvoice = prefs.getInt('last_invoice_number') ?? 0;
      int newInvoiceNumber = lastInvoice + 1;
      await prefs.setInt('last_invoice_number', newInvoiceNumber);

      final invoiceNumber = newInvoiceNumber.toString();

      // ================= CREATE PDF =================
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (_) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ================= TOP HEADER =================
                pw.Container(
                  padding: const pw.EdgeInsets.all(18),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.indigo800,
                    borderRadius: pw.BorderRadius.circular(18),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'STOCK FLOW',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Invoice / Billing System',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'INVOICE',
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.Text(
                            'NO:- $invoiceNumber',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 22),

                // ================= INVOICE INFO =================
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Invoice Date',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.Text(
                            formatter.format(controller.selectedDate.value),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Payment Method',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.Text(
                            controller.selectedPaymentMethod.value,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 24),

                // ================= TABLE HEADER =================
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 10, horizontal: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: _tableHeader(),
                ),

                pw.SizedBox(height: 6),

                // ================= ITEMS =================
                ...controller.cartItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final price = item['price'] as double;
                  final qty = item['quantity'] as int;
                  final total = price * qty;

                  return pw.Container(
                    color: index.isEven
                        ? PdfColors.grey50
                        : PdfColor.fromInt(0x00FFFFFF),
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: _tableRow(
                      item['name'],
                      qty.toString(),
                      '₹${price.toStringAsFixed(2)}',
                      '₹${total.toStringAsFixed(2)}',
                    ),
                  );
                }),

                pw.Divider(thickness: 1.5),

                pw.SizedBox(height: 18),

                // ================= SUMMARY =================
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green100,
                      borderRadius: pw.BorderRadius.circular(14),
                    ),
                    child: pw.Column(
                      children: [
                        _summaryRow('Subtotal', controller.subtotal),
                        _summaryRow('Discount', -controller.discountAmount),
                        pw.Divider(),
                        _summaryRow(
                          'Total Amount',
                          controller.totalAmount,
                          bold: true,
                          fontSize: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                // ================= FOOTER =================
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'This is a system generated invoice. Thank you!',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // ================= SAVE TO DOWNLOADS =================
      final bytes = await pdf.save();

      Directory downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final file = File('${downloadDir.path}/invoice_$invoiceNumber.pdf');

      await file.writeAsBytes(bytes, flush: true);

      // ================= SUCCESS SNACKBAR =================
      Get.snackbar(
        'Success!',
        'Invoice #$invoiceNumber saved to Downloads',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      // ================= ERROR SNACKBAR =================
      Get.snackbar(
        'Error!',
        'Failed to generate invoice. ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // ================= HELPERS =================

  static pw.Widget _tableHeader() {
    return pw.Row(
      children: [
        _cell('Item', flex: 3, bold: true),
        _cell('Qty', flex: 1, bold: true, align: pw.TextAlign.center),
        _cell('Price', flex: 2, bold: true, align: pw.TextAlign.right),
        _cell('Total', flex: 2, bold: true, align: pw.TextAlign.right),
      ],
    );
  }

  static pw.Widget _tableRow(
    String item,
    String qty,
    String price,
    String total,
  ) {
    return pw.Row(
      children: [
        _cell(item, flex: 3),
        _cell(qty, flex: 1, align: pw.TextAlign.center),
        _cell(price, flex: 2, align: pw.TextAlign.right),
        _cell(total, flex: 2, align: pw.TextAlign.right, bold: true),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    int flex = 1,
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _summaryRow(
    String label,
    double value, {
    bool bold = false,
    double fontSize = 14,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : null,
            ),
          ),
          pw.Text(
            '₹${value.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
