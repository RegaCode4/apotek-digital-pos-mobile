import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/sale.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';

class TransactionDetailDialog extends StatelessWidget {
  final Sale sale;

  const TransactionDetailDialog({super.key, required this.sale});

  static void show(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder: (_) => TransactionDetailDialog(sale: sale),
    );
  }

  void _openReceiptUrl(BuildContext context) async {
    final urlStr = ApiEndpoints.receiptUrl(sale.id);
    final uri = Uri.parse(urlStr);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.invoiceNo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrutal,
                      ),
                    ),
                    Text(
                      DateFormatter.parseAndFormat(sale.saleDate),
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  icon: const HeroIcon(HeroIcons.xMark),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Row
                    _buildInfoRow('Pembeli', sale.buyerName),
                    _buildInfoRow('Kasir', sale.cashier?.name ?? 'Kasir'),
                    _buildInfoRow('Metode Bayar', sale.paymentMethod.toUpperCase()),
                    if (sale.bpjsClaimNo != null)
                      _buildInfoRow('No. Klaim BPJS', sale.bpjsClaimNo!),
                    const SizedBox(height: 12),

                    const Text(
                      'Daftar Item Obat:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrutal,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Items list
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sale.saleItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final item = sale.saleItems[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.medicine?.name ?? 'Obat #${item.medicineId}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textMuted),
                                  ),
                                  if (item.prescriptionNo != null)
                                    Text(
                                      'Resep: ${item.prescriptionNo}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(item.subtotal),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textInk,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 20),

                    // Price Calculations
                    _buildCalcRow('Subtotal', CurrencyFormatter.format(sale.subtotal)),
                    if (sale.discountAmount > 0)
                      _buildCalcRow('Diskon', '- ${CurrencyFormatter.format(sale.discountAmount)}',
                          color: AppColors.danger),
                    if (sale.taxAmount > 0)
                      _buildCalcRow('PPN (11%)', CurrencyFormatter.format(sale.taxAmount)),
                    const SizedBox(height: 8),
                    _buildCalcRow('Grand Total', CurrencyFormatter.format(sale.grandTotal),
                        isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBrutal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const HeroIcon(HeroIcons.documentArrowDown, size: 18),
                label: const Text('Buka Struk PDF'),
                onPressed: () => _openReceiptUrl(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.darkBrutal : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.primary : (color ?? AppColors.textInk),
            ),
          ),
        ],
      ),
    );
  }
}
