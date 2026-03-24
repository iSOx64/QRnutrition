enum ScanSourceType {
  barcode,
  qrcode,
  manual,
  unknown,
}

extension ScanSourceTypeX on ScanSourceType {
  String get value {
    switch (this) {
      case ScanSourceType.barcode:
        return 'barcode';
      case ScanSourceType.qrcode:
        return 'qrcode';
      case ScanSourceType.manual:
        return 'manual';
      case ScanSourceType.unknown:
        return 'unknown';
    }
  }

  static ScanSourceType fromValue(String? value) {
    switch (value) {
      case 'barcode':
        return ScanSourceType.barcode;
      case 'qrcode':
        return ScanSourceType.qrcode;
      case 'manual':
        return ScanSourceType.manual;
      default:
        return ScanSourceType.unknown;
    }
  }
}

class ScanResultModel {
  const ScanResultModel({
    required this.rawValue,
    required this.sourceType,
  });

  final String rawValue;
  final ScanSourceType sourceType;

  bool get isBarcode => sourceType == ScanSourceType.barcode;

  bool get isQrCode => sourceType == ScanSourceType.qrcode;
}

