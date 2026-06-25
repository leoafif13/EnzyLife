import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/format_helper.dart';

class InvoiceHelper {
  static Future<void> printInvoice(OrderModel order) async {
    try {
      final user = await AuthService.getUser();
      final String rawName = user?['name']?.toString().trim() ?? '';
      final String userName = (rawName.isEmpty || rawName == '-') ? 'Pelanggan EnzyLife' : rawName;
      final String userEmail = user?['email'] ?? '-';

      final doc = pw.Document();

      final pw.ThemeData theme = pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Branding & Title
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'EnzyLife',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#2E7D32'),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Eco Enzyme Solutions & Products',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
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
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '#INVC-${order.id}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 16),

                  // Client and Transaction Info
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'DITAGIHKAN KEPADA:',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              userName,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              userEmail,
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            _buildPdfMetaRow('Tanggal:', formatDate(order.createdAt.split('T')[0])),
                            _buildPdfMetaRow('Status Pesanan:', order.statusDescription),
                            _buildPdfMetaRow('Metode Bayar:', order.metodePembayaran),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),

                  // Table
                  pw.Text(
                    'RINCIAN PEMBELIAN',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Headers
                  pw.Container(
                    color: PdfColor.fromHex('#E8F5E9'),
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(width: 20, child: pw.Text('No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        pw.Expanded(child: pw.Text('Produk', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        pw.SizedBox(width: 40, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center)),
                        pw.SizedBox(width: 80, child: pw.Text('Harga', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right)),
                        pw.SizedBox(width: 90, child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right)),
                      ],
                    ),
                  ),

                  // Rows
                  ...List.generate(order.items.length, (idx) {
                    final item = order.items[idx];
                    final isEven = idx % 2 == 0;
                    return pw.Container(
                      color: isEven ? PdfColors.white : PdfColor.fromHex('#F9F9F9'),
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(width: 20, child: pw.Text('${idx + 1}', style: pw.TextStyle(fontSize: 10))),
                          pw.Expanded(child: pw.Text(item.product?.name ?? 'Produk', style: pw.TextStyle(fontSize: 10))),
                          pw.SizedBox(width: 40, child: pw.Text('${item.quantity}', style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
                          pw.SizedBox(width: 80, child: pw.Text(formatPrice(item.price), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                          pw.SizedBox(width: 90, child: pw.Text(formatPrice(item.subtotal), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    );
                  }),

                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 8),

                  // Rincian Biaya
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildPdfMetaRow('Subtotal Belanja:', formatPrice(order.items.fold(0, (sum, item) => sum + item.subtotal))),
                          _buildPdfMetaRow('Ongkos Kirim:', order.jenisCod == 'BAYAR_DI_RUMAH' ? formatPrice(15000) : 'Gratis'),
                          _buildPdfMetaRow('Biaya Admin:', formatPrice(2000)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 8),

                  // Total
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        'TOTAL PEMBAYARAN:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Text(
                        formatPrice(order.totalHarga),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                          color: PdfColor.fromHex('#2E7D32'),
                        ),
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  // Footer
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Terima kasih telah berbelanja di EnzyLife!',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Pembelian Anda turut berkontribusi dalam mendukung gerakan ramah lingkungan.',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Text(
                          'Dokumen ini sah dan diterbitkan secara digital oleh EnzyLife.',
                          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400, fontStyle: pw.FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => doc.save(),
        name: 'Invoice_EnzyLife_${order.id}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  static pw.Widget _buildPdfMetaRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
