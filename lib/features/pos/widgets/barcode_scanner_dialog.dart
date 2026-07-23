import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/theme/app_colors.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BarcodeScannerDialog(),
    );
  }

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  final TextEditingController _manualBarcodeController = TextEditingController();
  MobileScannerController? controller;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isLoadingPermission = true;
  bool _isCameraSupported = true;
  bool _isManualMode = false;
  bool isScanned = false;
  bool isTorchOn = false;
  String? _initErrorMessage;

  @override
  void initState() {
    super.initState();
    _checkPlatformAndInitialize();
  }

  void _checkPlatformAndInitialize() {
    if (kIsWeb) {
      _isCameraSupported = true;
    } else {
      _isCameraSupported = Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    }

    if (!_isCameraSupported) {
      setState(() {
        _isManualMode = true;
        _isLoadingPermission = false;
      });
    } else {
      _checkPermissionAndInitialize();
    }
  }

  Future<void> _checkPermissionAndInitialize() async {
    setState(() {
      _isLoadingPermission = true;
      _initErrorMessage = null;
    });

    try {
      final status = await Permission.camera.request();
      if (!mounted) return;

      if (status.isGranted) {
        controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
          torchEnabled: false,
          autoStart: true,
        );
      }

      setState(() {
        _permissionStatus = status;
        _isLoadingPermission = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initErrorMessage = e.toString();
        _isLoadingPermission = false;
        _isManualMode = true;
      });
    }
  }

  @override
  void dispose() {
    _manualBarcodeController.dispose();
    try {
      controller?.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _handlePop([String? result]) async {
    if (isScanned && result == null) return;
    if (mounted) {
      setState(() {
        isScanned = true;
      });
    }
    if (controller != null) {
      try {
        await controller!.stop();
      } catch (_) {}
    }
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  void _submitManualBarcode() {
    final code = _manualBarcodeController.text.trim();
    if (code.isNotEmpty) {
      _handlePop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 480),
        child: Column(
          children: [
            // Header Dialog
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    HeroIcon(HeroIcons.qrCode, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Pindai Barcode Obat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrutal,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (!_isManualMode && _permissionStatus.isGranted && controller != null)
                      IconButton(
                        icon: HeroIcon(
                          isTorchOn ? HeroIcons.sun : HeroIcons.bolt,
                          color: isTorchOn ? Colors.amber : AppColors.darkBrutal,
                        ),
                        tooltip: 'Senter',
                        onPressed: () async {
                          try {
                            await controller!.toggleTorch();
                            if (mounted) {
                              setState(() {
                                isTorchOn = !isTorchOn;
                              });
                            }
                          } catch (_) {}
                        },
                      ),
                    IconButton(
                      icon: const HeroIcon(HeroIcons.xMark),
                      onPressed: () => _handlePop(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Mode Selector Tabs (Kamera / Manual)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBrutal, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _isCameraSupported
                          ? () {
                              setState(() {
                                _isManualMode = false;
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isManualMode ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HeroIcon(
                              HeroIcons.camera,
                              size: 16,
                              color: !_isManualMode ? Colors.white : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kamera',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_isManualMode ? Colors.white : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isManualMode = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isManualMode ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HeroIcon(
                              HeroIcons.pencilSquare,
                              size: 16,
                              color: _isManualMode ? Colors.white : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Input Manual',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isManualMode ? Colors.white : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Dialog Main Content (Camera vs Manual)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _isManualMode ? _buildManualInputContent() : _buildCameraScannerContent(),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              _isManualMode
                  ? 'Ketik nomor kode barcode obat lalu tekan Gunakan'
                  : 'Arahkan kamera ke barcode pada kemasan obat',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputContent() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HeroIcon(
            HeroIcons.qrCode,
            size: 44,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Masukkan Kode Barcode',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrutal,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dukungan USB Scanner otomatis mengetik kode barcode di sini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _manualBarcodeController,
            autofocus: true,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitManualBarcode(),
            decoration: const InputDecoration(
              hintText: 'Contoh: 899999900001',
              prefixIcon: Icon(Icons.qr_code, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _submitManualBarcode,
            icon: const HeroIcon(HeroIcons.checkCircle, size: 18),
            label: const Text('Gunakan Barcode Ini'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraScannerContent() {
    if (!_isCameraSupported) {
      return Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeroIcon(
              HeroIcons.computerDesktop,
              color: AppColors.textMuted,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Scanner kamera fisik didukung di Android/iOS.\nGunakan mode Input Manual di platform ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkBrutal,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isManualMode = true;
                });
              },
              icon: const HeroIcon(HeroIcons.pencilSquare, size: 16),
              label: const Text('Buka Input Manual'),
            ),
          ],
        ),
      );
    }

    if (_isLoadingPermission) {
      return Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_permissionStatus.isGranted || _initErrorMessage != null) {
      final isPermanentlyDenied = _permissionStatus.isPermanentlyDenied;

      return Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeroIcon(
              HeroIcons.exclamationTriangle,
              color: AppColors.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              _initErrorMessage != null
                  ? 'Gagal memuat sistem kamera.'
                  : isPermanentlyDenied
                      ? 'Izin kamera ditolak secara permanen. Mohon aktifkan izin kamera di Pengaturan HP Anda.'
                      : 'Aplikasi memerlukan izin kamera untuk memindai barcode.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkBrutal,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (isPermanentlyDenied) {
                      openAppSettings();
                    } else {
                      _checkPermissionAndInitialize();
                    }
                  },
                  icon: HeroIcon(
                    isPermanentlyDenied ? HeroIcons.cog6Tooth : HeroIcons.arrowPath,
                    size: 16,
                  ),
                  label: Text(isPermanentlyDenied ? 'Pengaturan' : 'Izinkan'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isManualMode = true;
                    });
                  },
                  icon: const HeroIcon(HeroIcons.pencilSquare, size: 16),
                  label: const Text('Input Manual'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (controller == null) {
      return Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: Text('Gagal inisialisasi kamera'),
        ),
      );
    }

    return MobileScanner(
      controller: controller,
      errorBuilder: (context, error, child) {
        return Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HeroIcon(
                HeroIcons.exclamationTriangle,
                color: AppColors.danger,
                size: 36,
              ),
              const SizedBox(height: 10),
              Text(
                'Gagal memuat kamera: ${error.errorCode.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkBrutal,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      controller?.start();
                    },
                    icon: const HeroIcon(HeroIcons.arrowPath, size: 14),
                    label: const Text('Coba Lagi'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isManualMode = true;
                      });
                    },
                    icon: const HeroIcon(HeroIcons.pencilSquare, size: 14),
                    label: const Text('Input Manual'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      placeholderBuilder: (context, child) {
        return Container(
          color: Colors.black12,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      onDetect: (capture) async {
        if (isScanned) return;
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          final rawValue = barcode.rawValue;
          if (rawValue != null && rawValue.isNotEmpty) {
            await _handlePop(rawValue);
            break;
          }
        }
      },
    );
  }
}



