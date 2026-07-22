import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import '../../../core/models/cart_item.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/neubrutal_style.dart';
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: NeubrutalStyle.card(
        backgroundColor: AppColors.surface,
        borderColor: isPrescriptionMissing ? AppColors.warning : AppColors.darkBrutal,
        borderWidth: 1.5,
        shadowOffset: 2.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Item Name & Unit Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.medicine.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrutal,
                            ),
                          ),
                        ),
                        if (requiresPrescription) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.warningSoft,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.warning, width: 1),
                            ),
                            child: const Text(
                              'Resep',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.format(item.unitPrice)} / ${item.medicine.unit}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Quantity Controls (- 1 +)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBrutal, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => onQuantityChanged(item.quantity - 1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: HeroIcon(HeroIcons.minus, size: 14, color: AppColors.darkBrutal),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 24),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrutal,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: item.quantity < item.medicine.stock
                          ? () => onQuantityChanged(item.quantity + 1)
                          : null,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: HeroIcon(
                          HeroIcons.plus,
                          size: 14,
                          color: item.quantity < item.medicine.stock
                              ? AppColors.darkBrutal
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Subtotal Price
              Text(
                CurrencyFormatter.format(item.subtotal),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),

              // Remove (X) button
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.danger, width: 1.2),
                  ),
                  child: const HeroIcon(HeroIcons.xMark, size: 14, color: AppColors.danger),
                ),
              ),
            ],
          ),

          // Prescription No Input (If required)
          if (requiresPrescription) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.prescriptionNo,
              onChanged: onPrescriptionChanged,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                hintText: 'Masukkan No. Resep Dokter *',
                hintStyle: const TextStyle(color: AppColors.warning, fontSize: 11),
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
