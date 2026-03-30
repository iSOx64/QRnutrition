import '../models/scan_result_model.dart';

class ScannerService {
  ScanResultModel parseRawValue(
    String rawValue, {
    ScanSourceType? hint,
  }) {
    final cleaned = rawValue.trim();
    final sourceType = hint ?? _inferSourceType(cleaned);
    return ScanResultModel(
      rawValue: cleaned,
      sourceType: sourceType,
    );
  }

  ScanSourceType _inferSourceType(String value) {
    if (value.isEmpty) return ScanSourceType.unknown;
    // On utilise uniquement des codes-barres.
    return ScanSourceType.barcode;
  }
}
