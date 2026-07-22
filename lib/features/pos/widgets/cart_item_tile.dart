import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import '../../../core/models/cart_item.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/currency_formatter.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<String> onPrescriptionChanged;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onPrescriptionChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final requiresPrescription = item.medicine.requiresPrescription;
    final isPrescriptionMissing =
        requiresPrescription && (item.prescriptionNo == null || item.prescriptionNo!.trim().isEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrescriptionMissing
              ? AppColors.warning.withAlpha(204)
              : AppColors.borderSoft,
          width: isPrescriptionMissing ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.medicine.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textInk,
                            ),
                          ),
                        ),
                        if (requiresPrescription) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warningSoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Wajib Resep',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${CurrencyFormatter.format(item.unitPrice)} / ${item.medicine.unit}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const HeroIcon(HeroIcons.trash, size: 18, color: AppColors.danger),
                onPressed: onRemove,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Qty Selector & Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Qty Incrementation Buttons (+/-)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => onQuantityChanged(item.quantity - 1),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: HeroIcon(HeroIcons.minus, size: 16, color: AppColors.darkBrutal),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textInk,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: item.quantity < item.medicine.stock
                          ? () => onQuantityChanged(item.quantity + 1)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: HeroIcon(
                          HeroIcons.plus,
                          size: 16,
                          color: item.quantity < item.medicine.stock
                              ? AppColors.darkBrutal
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subtotal Text
              Text(
                CurrencyFormatter.format(item.subtotal),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          // Prescription No Input (If required)
          if (requiresPrescription) ...[
            const SizedBox(height: 10),
            TextFormField(
              initialValue: item.prescriptionNo,
              onChanged: onPrescriptionChanged,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                hintText: 'Masukkan No. Resep Dokter *',
                hintStyle: const TextStyle(color: AppColors.warning, fontSize: 12),
                fillColor: AppColors.warningSoft.withAlpha(77),
                prefixIcon: const HeroIcon(HeroIcons.documentText,
                    size: 16, color: AppColors.warning),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
