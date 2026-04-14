import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Presentation/sales/PDFdowload.dart';

class InvoicePage extends GetView<SalesController> {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formatter = DateFormat('dd MMM, yyyy');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : PremiumTheme.lightTextPrimary,
            size: 20
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Review Invoice",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Payment Method"),
            const SizedBox(height: 16),
            _buildPaymentOptions(context),
            const SizedBox(height: 32),
            _buildInvoiceCard(context, formatter),
            const SizedBox(height: 40),
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: theme.brightness == Brightness.dark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _paymentChip(context, 'Cash', Icons.payments_outlined),
          const SizedBox(width: 12),
          _paymentChip(context, 'Card', Icons.credit_card_rounded),
          const SizedBox(width: 12),
          _paymentChip(context, 'UPI', Icons.qr_code_2_rounded),
        ],
      ),
    );
  }

  Widget _paymentChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selected = controller.selectedPaymentMethod.value == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedPaymentMethod.value = label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: selected
              ? PremiumTheme.primaryColor
              : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? PremiumTheme.primaryColor : theme.dividerColor,
              width: 1.5,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: PremiumTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : theme.hintColor,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: selected ? Colors.white : (isDark ? PremiumTheme.darkTextPrimary : PremiumTheme.lightTextPrimary),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, DateFormat formatter) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PremiumTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INVOICE',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: PremiumTheme.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => Text(
                      formatter.format(controller.selectedDate.value).toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    )),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? PremiumTheme.darkBg : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      )
                    ]
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: PremiumTheme.primaryColor, size: 32),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(flex: 3, child: Text('ITEM', style: _tableHeaderStyle(theme))),
                    Expanded(flex: 1, child: Text('QTY', textAlign: TextAlign.center, style: _tableHeaderStyle(theme))),
                    Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right, style: _tableHeaderStyle(theme))),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: theme.dividerColor, thickness: 1),
                const SizedBox(height: 16),

                Obx(() => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.cartItems.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: theme.dividerColor.withValues(alpha: 0.5), thickness: 0.5, indent: 0, endIndent: 0),
                  ),
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    final price = item['price'] as double;
                    final quantity = item['quantity'] as int;
                    final total = price * quantity;

                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹${price.toStringAsFixed(2)} / unit",
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            quantity.toString(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹${total.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )),

                const SizedBox(height: 32),
                Divider(color: theme.dividerColor, thickness: 2),
                const SizedBox(height: 24),

                Obx(() => Column(
                  children: [
                    _buildSummaryRow(context, "Subtotal", controller.subtotal),
                    const SizedBox(height: 12),
                    _buildSummaryRow(context, "Discount Applied", controller.discountAmount, isDiscount: true),
                  ],
                )),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "TOTAL PAYABLE",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF10B981),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Obx(() => Text(
                        "₹${controller.totalAmount.toStringAsFixed(2)}",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF10B981),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _tableHeaderStyle(ThemeData theme) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w900,
      color: theme.hintColor,
      letterSpacing: 1.5,
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double value, {bool isDiscount = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          "${isDiscount ? '-' : ''} ₹${value.abs().toStringAsFixed(2)}",
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDiscount ? PremiumTheme.secondaryColor : (theme.brightness == Brightness.dark ? Colors.white : PremiumTheme.lightTextPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            controller.completeSale();
            Get.back();
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 24),
              SizedBox(width: 12),
              Text("COMPLETE SALE", style: TextStyle(letterSpacing: 1)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => PdfDowload.generateInvoicePdf(controller),
          style: OutlinedButton.styleFrom(
            foregroundColor: PremiumTheme.secondaryColor,
            side: const BorderSide(color: PremiumTheme.secondaryColor, width: 2),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf_rounded, size: 22),
              SizedBox(width: 12),
              Text("EXPORT PDF", style: TextStyle(letterSpacing: 1)),
            ],
          ),
        ),
      ],
    );
  }
}
