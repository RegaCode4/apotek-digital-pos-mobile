import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/neubrutal_style.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/app_logo.dart';
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
  final _categoryScrollController = ScrollController();

  final List<String> _categories = const [
    'Semua',
    'Anti-Infeksi Sistemik',
    'Antineoplastik',
    'Antiparasit, Insektisida & Repelen',
    'Berbagai Macam (Various)',
    'Darah & Organ Pembentuk Darah',
    'Dermatologikal',
    'Organ Sensorik',
    'Sistem Endokrin',
    'Sistem Genitourinari & Hormon Seks',
    'Sistem Kardiovaskular',
    'Sistem Musculoskeletal',
    'Sistem Pencernaan & Metabolisme',
    'Sistem Pernapasan',
    'Sistem Saraf Pusat',
    'Vitamin dan Suplemen',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _buyerNameController.dispose();
    _discountController.dispose();
    _bpjsClaimController.dispose();
    _categoryScrollController.dispose();
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
    cartNotifier.setBuyerName(
        _buyerNameController.text.trim().isEmpty ? 'Umum' : _buyerNameController.text.trim());
    if (_bpjsClaimController.text.isNotEmpty) {
      cartNotifier.setBpjsClaimNo(_bpjsClaimController.text.trim());
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

    final todayFormatted = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 52,
        title: Row(
          children: [
            const AppLogo(size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apotek Digital POS',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Kasir: ${authState.user?.name ?? 'Kasir Apotek'}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Date Clock display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBrutal, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HeroIcon(HeroIcons.clock, size: 14, color: AppColors.darkBrutal),
                const SizedBox(width: 4),
                Text(
                  todayFormatted,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkBrutal),
                ),
              ],
            ),
          ),
          // History Button
          IconButton(
            icon: const HeroIcon(HeroIcons.clock, size: 20),
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
                size: 20, color: AppColors.danger),
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
          const SizedBox(width: 6),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.dangerSoft,
                child: Row(
                  children: [
                    const HeroIcon(HeroIcons.exclamationCircle,
                        color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transactionState.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ALWAYS 2-Panel Landscape Web Layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT PANEL: Search & Medicine Catalog
                    Expanded(
                      flex: 6,
                      child: _buildLeftPanel(context, searchState),
                    ),
                    const SizedBox(width: 10),

                    // RIGHT PANEL: Shopping Cart & Checkout
                    Expanded(
                      flex: 5,
                      child: _buildRightPanel(context, cartState),
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

  Widget _buildLeftPanel(BuildContext context, MedicineSearchState searchState) {
    final filteredList = searchState.filteredMedicines;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: NeubrutalStyle.card(
        shadowOffset: 3.0,
        borderRadius: 14.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  HeroIcon(HeroIcons.magnifyingGlass, color: AppColors.primary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Cari Obat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrutal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: NeubrutalStyle.badge(
                  backgroundColor: AppColors.primarySoft,
                  borderColor: AppColors.primary,
                ),
                child: Text(
                  '${filteredList.length} Obat',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrutal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Search Bar & Barcode Scanner
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Ketik nama merek atau generik...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: _openBarcodeScanner,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: NeubrutalStyle.card(
                    backgroundColor: AppColors.primarySoft,
                    shadowOffset: 2.0,
                    borderRadius: 10.0,
                  ),
                  child: const HeroIcon(
                    HeroIcons.qrCode,
                    color: AppColors.darkBrutal,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Category Filter Chips
          SizedBox(
            height: 32,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _categoryScrollController.animateTo(
                      (_categoryScrollController.offset - 200).clamp(0.0, _categoryScrollController.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: const HeroIcon(HeroIcons.chevronLeft, size: 16, color: AppColors.darkBrutal),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  tooltip: 'Geser Kiri',
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _categoryScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = searchState.selectedCategory == cat;

                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: InkWell(
                          onTap: () {
                            ref.read(medicineSearchProvider.notifier).selectCategory(cat);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primarySoft : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.darkBrutal,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      const BoxShadow(
                                        color: AppColors.darkBrutal,
                                        offset: Offset(1.2, 1.2),
                                        blurRadius: 0,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: AppColors.darkBrutal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _categoryScrollController.animateTo(
                      (_categoryScrollController.offset + 200).clamp(0.0, _categoryScrollController.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: const HeroIcon(HeroIcons.chevronRight, size: 16, color: AppColors.darkBrutal),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  tooltip: 'Geser Kanan',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Medicine Grid
          Expanded(
            child: searchState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : searchState.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const HeroIcon(HeroIcons.exclamationTriangle,
                                  size: 36, color: AppColors.danger),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal memuat data obat',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.darkBrutal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                searchState.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                icon: const HeroIcon(HeroIcons.arrowPath, size: 14),
                                label: const Text('Coba Lagi', style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  ref.read(medicineSearchProvider.notifier).refresh();
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const HeroIcon(HeroIcons.archiveBoxXMark,
                                      size: 36, color: AppColors.textMuted),
                                  const SizedBox(height: 8),
                                  Text(
                                    searchState.selectedCategory != 'Semua'
                                        ? 'Tidak ada obat dalam kategori "${searchState.selectedCategory}"'
                                        : searchState.query.isNotEmpty
                                            ? 'Obat "${searchState.query}" tidak ditemukan'
                                            : 'Belum ada data obat di database',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.darkBrutal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (searchState.selectedCategory != 'Semua') ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(medicineSearchProvider.notifier)
                                            .selectCategory('Semua');
                                      },
                                      child: Text(
                                        'Tampilkan Semua Kategori (${searchState.medicines.length} Obat)',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              int crossCount = 2;
                              if (constraints.maxWidth > 650) {
                                crossCount = 4;
                              } else if (constraints.maxWidth > 420) {
                                crossCount = 3;
                              }

                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossCount,
                                  childAspectRatio: crossCount >= 4 ? 1.15 : (crossCount == 3 ? 1.05 : 1.0),
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final medicine = filteredList[index];
                                  return MedicineCard(
                                    medicine: medicine,
                                    onAddToCart: () {
                                      ref.read(cartProvider.notifier).addToCart(medicine);
                                    },
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context, CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: NeubrutalStyle.card(
        shadowOffset: 3.0,
        borderRadius: 14.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart Header (Fixed at top of right panel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const HeroIcon(HeroIcons.shoppingCart, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'Keranjang Belanja',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrutal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: NeubrutalStyle.badge(
                      backgroundColor: AppColors.primarySoft,
                      borderColor: AppColors.primary,
                    ),
                    child: Text(
                      '${cartState.items.length} item',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrutal,
                      ),
                    ),
                  ),
                ],
              ),
              if (cartState.items.isNotEmpty)
                InkWell(
                  onTap: () {
                    ref.read(cartProvider.notifier).resetCart();
                  },
                  child: const Row(
                    children: [
                      HeroIcon(HeroIcons.trash, size: 14, color: AppColors.danger),
                      SizedBox(width: 3),
                      Text(
                        'Kosongkan',
                        style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Scrollable Body for Cart Items & Payment Checkout
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cartState.items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HeroIcon(HeroIcons.shoppingBag, size: 38, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text(
                            'Keranjang masih kosong',
                            style: TextStyle(
                              color: AppColors.darkBrutal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pilih obat di panel sebelah kiri untuk menambah pesanan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Cart Items List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartState.items.length,
                      itemBuilder: (context, index) {
                        final item = cartState.items[index];
                        return CartItemTile(
                          item: item,
                          onQuantityChanged: (qty) {
                            ref.read(cartProvider.notifier).updateQuantity(item.medicine.id, qty);
                          },
                          onPrescriptionChanged: (prescriptionNo) {
                            ref
                                .read(cartProvider.notifier)
                                .updatePrescriptionNo(item.medicine.id, prescriptionNo);
                          },
                          onRemove: () {
                            ref.read(cartProvider.notifier).removeFromCart(item.medicine.id);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Price Summary Container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: NeubrutalStyle.card(
                        backgroundColor: AppColors.surfaceMuted,
                        borderColor: AppColors.darkBrutal,
                        shadowOffset: 1.5,
                        borderRadius: 10.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              Text(
                                CurrencyFormatter.format(cartState.subtotal),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBrutal),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Discount Input Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Diskon (Rp)',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              SizedBox(
                                width: 110,
                                height: 32,
                                child: TextField(
                                  controller: _discountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  onChanged: (val) {
                                    final discount = double.tryParse(val) ?? 0.0;
                                    ref.read(cartProvider.notifier).setDiscountAmount(discount);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Tax Toggle Switch (11% PPN)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text('PPN 11%',
                                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  const SizedBox(width: 4),
                                  SizedBox(
                                    height: 20,
                                    child: Switch(
                                      value: cartState.isTaxEnabled,
                                      activeThumbColor: AppColors.primary,
                                      onChanged: (val) {
                                        ref.read(cartProvider.notifier).toggleTax(val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                CurrencyFormatter.format(cartState.taxAmount),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBrutal),
                              ),
                            ],
                          ),
                          const Divider(height: 12),

                          // Grand Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBrutal,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(cartState.grandTotal),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Customer Details Form
                    const Text(
                      'Nama Pembeli *',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrutal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _buyerNameController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: 'Nama lengkap pembeli...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Payment Method Selectors (4 distinct buttons: Cash, Transfer, BPJS, Asuransi)
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrutal,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildPaymentMethodGrid(cartState),

                    // BPJS Claim No input (if BPJS selected)
                    if (cartState.paymentMethod == 'bpjs') ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _bpjsClaimController,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'Nomor Klaim BPJS * (misal: BPJS-202607-0081)',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Action Submit Button
                    CustomButton(
                      text: 'Proses Transaksi',
                      icon: Icons.check_circle_outline,
                      onPressed: _handleCheckout,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodGrid(CartState cartState) {
    final methods = [
      {'id': 'cash', 'label': 'Cash'},
      {'id': 'transfer', 'label': 'Transfer'},
      {'id': 'bpjs', 'label': 'BPJS'},
      {'id': 'insurance', 'label': 'Asuransi'},
    ];

    return Row(
      children: methods.map((m) {
        final isSelected = cartState.paymentMethod == m['id'];
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 5),
            child: InkWell(
              onTap: () => ref.read(cartProvider.notifier).setPaymentMethod(m['id']!),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: NeubrutalStyle.card(
                  backgroundColor: isSelected ? AppColors.primarySoft : AppColors.surface,
                  borderColor: isSelected ? AppColors.primary : AppColors.darkBrutal,
                  borderWidth: isSelected ? 1.8 : 1.0,
                  borderRadius: 8.0,
                  shadowOffset: isSelected ? 2.0 : 1.0,
                ),
                child: Text(
                  m['label']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: AppColors.darkBrutal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
