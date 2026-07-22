import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/neubrutal_style.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../history/providers/transaction_provider.dart';
import '../../history/screens/history_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/medicine_search_provider.dart';
import '../widgets/barcode_scanner_dialog.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/medicine_card.dart';
import 'success_screen.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  final _buyerNameController = TextEditingController(text: 'Umum');
  final _discountController = TextEditingController();
  final _bpjsClaimController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _buyerNameController.dispose();
    _discountController.dispose();
    _bpjsClaimController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(medicineSearchProvider.notifier).searchMedicines(query);
  }

  void _openBarcodeScanner() async {
    final scannedCode = await BarcodeScannerDialog.show(context);
    if (scannedCode != null && scannedCode.isNotEmpty) {
      _searchController.text = scannedCode;
      _onSearchChanged(scannedCode);
    }
  }

  void _handleCheckout() async {
    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.setBuyerName(_buyerNameController.text);
    if (_bpjsClaimController.text.isNotEmpty) {
      cartNotifier.setBpjsClaimNo(_bpjsClaimController.text);
    }

    final sale = await ref.read(transactionProvider.notifier).submitTransaction();

    if (!mounted) return;
    if (sale != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SuccessScreen(sale: sale),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final searchState = ref.watch(medicineSearchProvider);
    final cartState = ref.watch(cartProvider);
    final transactionState = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const HeroIcon(
                HeroIcons.buildingStorefront,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apotek Digital POS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Kasir: ${authState.user?.name ?? 'Kasir'}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Riwayat Transaksi Button
          IconButton(
            icon: const HeroIcon(HeroIcons.clock, size: 22),
            tooltip: 'Riwayat Transaksi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          // Logout Button
          IconButton(
            icon: const HeroIcon(HeroIcons.arrowRightOnRectangle,
                size: 22, color: AppColors.danger),
            tooltip: 'Logout',
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LoadingOverlay(
        isLoading: transactionState.isProcessing,
        message: 'Memproses transaksi...',
        child: Column(
          children: [
            // Error banner if any
            if (transactionState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.dangerSoft,
                child: Row(
                  children: [
                    const HeroIcon(HeroIcons.exclamationCircle,
                        color: AppColors.danger, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        transactionState.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= PANEL ATAS: KATALOG & SEARCH OBAT =================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: NeubrutalStyle.card(
                        shadowOffset: 4.0,
                        borderRadius: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const HeroIcon(HeroIcons.magnifyingGlass,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Katalog & Pencarian Obat',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBrutal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Search Bar & Barcode Scanner
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  decoration: InputDecoration(
                                    hintText: 'Cari obat (nama, generik, produsen)...',
                                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 18),
                                            onPressed: () {
                                              _searchController.clear();
                                              _onSearchChanged('');
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: _openBarcodeScanner,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: NeubrutalStyle.card(
                                    backgroundColor: AppColors.primarySoft,
                                    shadowOffset: 2.0,
                                    borderRadius: 12.0,
                                  ),
                                  child: const HeroIcon(
                                    HeroIcons.qrCode,
                                    color: AppColors.darkBrutal,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Medicine Card Grid/List
                          if (searchState.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (searchState.medicines.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'Obat tidak ditemukan.',
                                  style: TextStyle(color: AppColors.textMuted),
                                ),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                                childAspectRatio: 0.82,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: searchState.medicines.length,
                              itemBuilder: (context, index) {
                                final medicine = searchState.medicines[index];
                                return MedicineCard(
                                  medicine: medicine,
                                  onAddToCart: () {
                                    ref.read(cartProvider.notifier).addToCart(medicine);
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ================= PANEL BAWAH: KERANJANG BELANJA & CHECKOUT =================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: NeubrutalStyle.card(
                        shadowOffset: 4.0,
                        borderRadius: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const HeroIcon(HeroIcons.shoppingCart,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Keranjang Belanja (${cartState.items.length})',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrutal,
                                    ),
                                  ),
                                ],
                              ),
                              if (cartState.items.isNotEmpty)
                                TextButton.icon(
                                  icon: const HeroIcon(HeroIcons.trash,
                                      size: 16, color: AppColors.danger),
                                  label: const Text(
                                    'Kosongkan',
                                    style: TextStyle(color: AppColors.danger, fontSize: 12),
                                  ),
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).resetCart();
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (cartState.items.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              alignment: Alignment.center,
                              child: const Column(
                                children: [
                                  HeroIcon(HeroIcons.shoppingBag,
                                      size: 40, color: AppColors.textMuted),
                                  SizedBox(height: 8),
                                  Text(
                                    'Keranjang masih kosong',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Tap (+) pada obat untuk menambah ke keranjang',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            // Cart items list
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cartState.items.length,
                              itemBuilder: (context, index) {
                                final item = cartState.items[index];
                                return CartItemTile(
                                  item: item,
                                  onQuantityChanged: (qty) {
                                    ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(item.medicine.id, qty);
                                  },
                                  onPrescriptionChanged: (prescriptionNo) {
                                    ref
                                        .read(cartProvider.notifier)
                                        .updatePrescriptionNo(item.medicine.id, prescriptionNo);
                                  },
                                  onRemove: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .removeFromCart(item.medicine.id);
                                  },
                                );
                              },
                            ),
                            const Divider(height: 24),

                            // Customer & Payment Details Form
                            const Text(
                              'Informasi Pelanggan & Pembayaran',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBrutal,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Buyer name
                            TextField(
                              controller: _buyerNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Pembeli',
                                hintText: 'misal: Budi Santoso (Default: Umum)',
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Payment method selector
                            Row(
                              children: [
                                const Text(
                                  'Metode Bayar: ',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: cartState.paymentMethod,
                                    isDense: true,
                                    decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'cash', child: Text('Tunai (Cash)')),
                                      DropdownMenuItem(value: 'transfer', child: Text('Transfer Bank')),
                                      DropdownMenuItem(value: 'bpjs', child: Text('BPJS Kesehatan')),
                                      DropdownMenuItem(value: 'insurance', child: Text('Asuransi Swasta')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        ref.read(cartProvider.notifier).setPaymentMethod(val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),

                            // BPJS Claim No input (if BPJS selected)
                            if (cartState.paymentMethod == 'bpjs') ...[
                              const SizedBox(height: 10),
                              TextField(
                                controller: _bpjsClaimController,
                                decoration: const InputDecoration(
                                  labelText: 'Nomor Klaim BPJS *',
                                  hintText: 'misal: BPJS-202506-0081',
                                  isDense: true,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),

                            // Summary Calculator
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Subtotal', style: TextStyle(fontSize: 13)),
                                      Text(
                                        CurrencyFormatter.format(cartState.subtotal),
                                        style: const TextStyle(
                                            fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Discount Input Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Diskon (Rp)', style: TextStyle(fontSize: 13)),
                                      SizedBox(
                                        width: 120,
                                        height: 36,
                                        child: TextField(
                                          controller: _discountController,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(fontSize: 12),
                                          decoration: const InputDecoration(
                                            hintText: '0',
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          onChanged: (val) {
                                            final discount = double.tryParse(val) ?? 0.0;
                                            ref
                                                .read(cartProvider.notifier)
                                                .setDiscountAmount(discount);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Tax Toggle Switch (11% PPN)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('PPN 11%', style: TextStyle(fontSize: 13)),
                                          Switch(
                                            value: cartState.isTaxEnabled,
                                            activeThumbColor: AppColors.primary,
                                            onChanged: (val) {
                                              ref.read(cartProvider.notifier).toggleTax(val);
                                            },
                                          ),
                                        ],
                                      ),
                                      Text(
                                        CurrencyFormatter.format(cartState.taxAmount),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),

                                  // Grand Total
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Grand Total',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkBrutal,
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(cartState.grandTotal),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            CustomButton(
                              text: 'Proses Transaksi',
                              icon: Icons.check_circle_outline,
                              onPressed: _handleCheckout,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
