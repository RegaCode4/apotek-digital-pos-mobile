import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/neubrutal_style.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_detail_dialog.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionProvider.notifier).fetchHistory(period: 'today');
    });
  }

  void _onFilterChanged(String period) {
    ref.read(transactionProvider.notifier).fetchHistory(period: period);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi Saya'),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: Row(
              children: [
                _buildFilterChip('today', 'Hari Ini', state.periodFilter),
                const SizedBox(width: 8),
                _buildFilterChip('this_week', 'Minggu Ini', state.periodFilter),
                const SizedBox(width: 8),
                _buildFilterChip('all', 'Semua', state.periodFilter),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: state.isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : state.history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const HeroIcon(HeroIcons.documentText,
                                size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada transaksi (${state.periodFilter})',
                              style: const TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.history.length,
                        itemBuilder: (context, index) {
                          final sale = state.history[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: NeubrutalStyle.card(
                              shadowOffset: 3.0,
                              borderRadius: 14.0,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => TransactionDetailDialog.show(context, sale),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.darkBrutal, width: 1.5),
                                        ),
                                        child: const HeroIcon(
                                          HeroIcons.receiptPercent,
                                          color: AppColors.darkBrutal,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  sale.invoiceNo,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.darkBrutal,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.surfaceMuted,
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(
                                                        color: AppColors.darkBrutal, width: 1),
                                                  ),
                                                  child: Text(
                                                    sale.paymentMethod.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.darkBrutal,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Pembeli: ${sale.buyerName} • ${sale.saleItems.length} item',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              DateFormatter.parseAndFormat(sale.saleDate),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            CurrencyFormatter.format(sale.grandTotal),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const HeroIcon(
                                            HeroIcons.chevronRight,
                                            size: 16,
                                            color: AppColors.textMuted,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, String currentKey) {
    final isSelected = key == currentKey;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBrutal, width: 1.5),
        boxShadow: [
          if (isSelected)
            const BoxShadow(
              color: AppColors.darkBrutal,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onFilterChanged(key),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkBrutal,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
