import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/sale.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/neubrutal_style.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/widgets/custom_button.dart';

class SuccessScreen extends StatelessWidget {
  final Sale sale;

  const SuccessScreen({super.key, required this.sale});

  void _openReceiptUrl(BuildContext context) async {
    final urlStr = ApiEndpoints.receiptUrl(sale.id);
    final uri = Uri.parse(urlStr);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka link struk: $urlStr')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error membuka struk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: NeubrutalStyle.card(
              shadowOffset: 5.0,
              borderRadius: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Badge Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const HeroIcon(
                    HeroIcons.checkCircle,
                    size: 56,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Transaksi Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrutal,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Struk penjualan telah berhasil dibuat',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),

                // Invoice Summary Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('No. Invoice', sale.invoiceNo, isBold: true),
                      const Divider(height: 16),
                      _buildSummaryRow('Pembeli', sale.buyerName),
                      const SizedBox(height: 6),
                      _buildSummaryRow('Metode Bayar', sale.paymentMethod.toUpperCase()),
                      const SizedBox(height: 6),
                      _buildSummaryRow('Waktu', DateFormatter.parseAndFormat(sale.saleDate)),
                      if (sale.bpjsClaimNo != null && sale.bpjsClaimNo!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildSummaryRow('No. Klaim BPJS', sale.bpjsClaimNo!),
                      ],
                      const Divider(height: 16),
                      _buildSummaryRow(
                        'Total Bayar',
                        CurrencyFormatter.format(sale.grandTotal),
                        isPrimaryBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                CustomButton(
                  text: 'Transaksi Baru',
                  icon: Icons.add_shopping_cart,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: 'Lihat Struk PDF',
                  icon: Icons.picture_as_pdf,
                  backgroundColor: AppColors.darkBrutal,
                  foregroundColor: Colors.white,
                  onPressed: () => _openReceiptUrl(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isPrimaryBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrimaryBold ? 16 : 13,
            fontWeight: (isBold || isPrimaryBold) ? FontWeight.bold : FontWeight.w500,
            color: isPrimaryBold
                ? AppColors.primary
                : isBold
                    ? AppColors.darkBrutal
                    : AppColors.textInk,
          ),
        ),
      ],
    );
  }
}
