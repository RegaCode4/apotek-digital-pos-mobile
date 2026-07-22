import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import '../../../core/models/medicine.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/neubrutal_style.dart';
import '../../../shared/utils/currency_formatter.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onAddToCart;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = medicine.isOutOfStock;
    final isLowStock = medicine.isLowStock;

    final cardBgColor = isOutOfStock
        ? AppColors.dangerSoft
        : isLowStock
            ? AppColors.warningSoft
            : AppColors.surface;

    final cardBorderColor = isOutOfStock
        ? AppColors.danger
        : isLowStock
            ? AppColors.warning
            : AppColors.darkBrutal;

    return Container(
      decoration: NeubrutalStyle.card(
        backgroundColor: cardBgColor,
        borderColor: cardBorderColor,
        shadowOffset: 3.0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOutOfStock ? null : onAddToCart,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header: Category Badge & Prescription Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (medicine.category != null)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: NeubrutalStyle.badge(
                            backgroundColor: AppColors.surfaceMuted,
                            borderColor: AppColors.darkBrutal,
                            borderRadius: 6.0,
                          ),
                          child: Text(
                            medicine.category!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrutal,
                            ),
                          ),
                        ),
                      ),
                    if (medicine.requiresPrescription) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: NeubrutalStyle.badge(
                          backgroundColor: AppColors.warningSoft,
                          borderColor: AppColors.warning,
                          borderRadius: 6.0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HeroIcon(HeroIcons.documentText,
                                size: 10, color: AppColors.warning),
                            SizedBox(width: 2),
                            Text(
                              'Resep',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Title & Generic Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        medicine.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock ? AppColors.danger : AppColors.darkBrutal,
                        ),
                      ),
                      if (medicine.genericName != null && medicine.genericName!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          medicine.genericName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Footer: Price, Stock & Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.format(medicine.price),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              HeroIcon(
                                HeroIcons.archiveBox,
                                size: 11,
                                color: isOutOfStock
                                    ? AppColors.danger
                                    : isLowStock
                                        ? AppColors.warning
                                        : AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  isOutOfStock
                                      ? 'Stok Habis'
                                      : 'Stok: ${medicine.stock} ${medicine.unit}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isOutOfStock || isLowStock
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isOutOfStock
                                        ? AppColors.danger
                                        : isLowStock
                                            ? AppColors.warning
                                            : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Add Button
                    Container(
                      decoration: BoxDecoration(
                        color: isOutOfStock ? Colors.grey.shade300 : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkBrutal, width: 1.5),
                      ),
                      child: InkWell(
                        onTap: isOutOfStock ? null : onAddToCart,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: HeroIcon(
                            HeroIcons.plus,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
