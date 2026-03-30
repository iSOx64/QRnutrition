import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_zxing/flutter_zxing.dart' hide ScannerOverlay;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/scan_result_model.dart';
import '../../data/repositories/scanner_repository.dart';
import '../controllers/scanner_controller.dart';
import '../widgets/scan_result_sheet.dart';
import '../widgets/scanner_overlay.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({
    super.key,
    this.openGalleryOnStart = false,
  });

  final bool openGalleryOnStart;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;
  late bool _useCamera;
  bool _didOpenPicker = false;

  @override
  void initState() {
    super.initState();
    _useCamera = !widget.openGalleryOnStart;
    _scannerController = MobileScannerController(autoStart: _useCamera);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _scanFromFiles(BuildContext providerContext) async {
    if (_isProcessing) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
      withReadStream: true,
    );
    if (result == null || result.files.isEmpty) return;
    final path = await _resolveImagePath(result.files.single);
    if (path == null) return;
    if (!mounted) return;

    setState(() => _isProcessing = true);
    try {
      if (_useCamera) {
        await _scannerController.stop();
      }
      // Use flutter_zxing for cross-platform barcode image decoding
      final code = await zx.readBarcodeImagePathString(
        path,
        DecodeParams(
          tryHarder: true,
          tryInverted: true,
          tryRotate: true,
        ),
      );

      final isBarcodeFormat =
          code.format != Format.qrCode && code.format != Format.none;
      String? rawValue = (code.isValid &&
              isBarcodeFormat &&
              code.text != null &&
              code.text!.isNotEmpty)
          ? code.text!
          : null;

      if (rawValue == null) {
        try {
          final capture = await _scannerController.analyzeImage(path);
          final barcode = capture?.barcodes.isEmpty ?? true
              ? null
              : capture!.barcodes.first;
          if (barcode?.format == BarcodeFormat.qrCode) {
            rawValue = null;
          } else {
          rawValue = _barcodeValue(barcode);
          }
        } catch (_) {
          // Ignore fallback errors
        }
      }

      if (rawValue == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aucun code-barres detecte. Utilise une image nette (PNG/JPG).',
            ),
          ),
        );
        return;
      }

      // Map zxing format to our source type
      final hint = _mapZxingFormat(code.format);
      final user = providerContext.read<AuthController>().state.user;
      if (user == null) return;

      final controller = providerContext.read<ScannerController>();
      await controller.processScannedCode(
        rawValue: rawValue,
        userId: user.uid,
        currentUser: user,
        hint: hint,
      );
      if (!mounted) return;
      await _handleScanResult(providerContext, controller);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(providerContext).showSnackBar(
        SnackBar(content: Text('Erreur analyse image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        if (_useCamera) {
          await _scannerController.start();
        }
      }
    }
  }

  Future<String?> _resolveImagePath(PlatformFile picked) async {
    final bytes = picked.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      final ext = (picked.extension ?? 'png').toLowerCase();
      if (ext == 'heic' || ext == 'heif') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format HEIC non supporte. Utilise PNG/JPG.'),
            ),
          );
        }
        return null;
      }
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    }

    final stream = picked.readStream;
    if (stream != null) {
      final ext = (picked.extension ?? 'png').toLowerCase();
      if (ext == 'heic' || ext == 'heif') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format HEIC non supporte. Utilise PNG/JPG.'),
            ),
          );
        }
        return null;
      }
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      final sink = file.openWrite();
      await stream.pipe(sink);
      await sink.flush();
      await sink.close();
      return file.path;
    }

    final directPath = picked.path;
    if (directPath == null || directPath.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier non supporte.')),
        );
      }
      return null;
    }

    if (directPath.startsWith('content://')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d ouvrir ce fichier. Choisis un PNG/JPG.'),
          ),
        );
      }
      return null;
    }

    final file = File(directPath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d acceder au fichier selectionne.'),
          ),
        );
      }
      return null;
    }
    return directPath;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.state.user;

    if (user == null) {
      return const Scaffold(body: LoadingState());
    }

    return ChangeNotifierProvider(
      create: (context) =>
          ScannerController(context.read<ScannerRepository>()),
      child: Builder(
        builder: (providerContext) {
          if (widget.openGalleryOnStart && !_didOpenPicker) {
            _didOpenPicker = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _scanFromFiles(providerContext);
            });
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Scanner code-barres')),
            body: _useCamera
                ? Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) async {
                          if (_isProcessing) return;
                          final barcode = capture.barcodes.isEmpty
                              ? null
                              : capture.barcodes.first;
                          if (barcode?.format == BarcodeFormat.qrCode) return;
                          final rawValue = _barcodeValue(barcode);
                          if (rawValue == null || rawValue.isEmpty) return;
                          _isProcessing = true;
                          final hint = _mapFormat(barcode?.format);
                          final controller =
                              providerContext.read<ScannerController>();
                          await controller.processScannedCode(
                            rawValue: rawValue,
                            userId: user.uid,
                            currentUser: user,
                            hint: hint,
                          );
                          if (!mounted) return;
                          await _handleScanResult(providerContext, controller);
                          _isProcessing = false;
                        },
                      ),
                      const ScannerOverlay(),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () =>
                                    _scanFromFiles(providerContext),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Importer un fichier'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FloatingActionButton(
                              heroTag: 'torch',
                              onPressed: () => _scannerController.toggleTorch(),
                              child: const Icon(Icons.flash_on),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: 64,
                            color:
                                Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Scanner un code-barres',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choisis un fichier image contenant un code-barres.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () =>
                                _scanFromFiles(providerContext),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Importer un fichier'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () async {
                              setState(() => _useCamera = true);
                              await _scannerController.start();
                            },
                            child: const Text('Utiliser la camera'),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  ScanSourceType? _mapFormat(BarcodeFormat? format) {
    if (format == null) return null;
    if (format == BarcodeFormat.qrCode) return null;
    return ScanSourceType.barcode;
  }

  ScanSourceType? _mapZxingFormat(int? format) {
    if (format == null || format == Format.none) return null;
    if (format == Format.qrCode) return null;
    // All other formats (EAN, UPC, Code128, etc.) are barcodes
    return ScanSourceType.barcode;
  }

  String? _barcodeValue(Barcode? barcode) {
    if (barcode == null) return null;
    return barcode.rawValue ?? barcode.displayValue;
  }

  Future<void> _handleScanResult(
    BuildContext context,
    ScannerController controller,
  ) async {
    if (controller.status == ViewStatus.success &&
        controller.product != null) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ScanResultSheet(
          product: controller.product!,
          onOpenDetails: () {
            Navigator.of(context).pop();
            context.push(AppRoute.productDetails.path, extra: controller.product);
          },
        ),
      );
    } else if (controller.status == ViewStatus.empty) {
      final canAdd = controller.canAddProduct;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produit introuvable'),
          action: canAdd
              ? SnackBarAction(
                  label: 'Ajouter',
                  onPressed: () => context.push(AppRoute.addProduct.path),
                )
              : null,
        ),
      );
    } else if (controller.status == ViewStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Erreur de scan'),
        ),
      );
    }
  }
}
