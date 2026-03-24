class AdminStats {
  AdminStats({
    required this.totalProducts,
    required this.totalScans,
    required this.totalUsers,
    required this.popularProducts,
    required this.recentScans,
  });

  final int totalProducts;
  final int totalScans;
  final int totalUsers;
  final List<PopularProductStat> popularProducts;
  final List<RecentScanActivity> recentScans;
}

class PopularProductStat {
  PopularProductStat({
    required this.productId,
    required this.productName,
    required this.scanCount,
  });

  final String productId;
  final String productName;
  final int scanCount;
}

class RecentScanActivity {
  RecentScanActivity({
    required this.scanId,
    required this.productName,
    required this.scannedAt,
  });

  final String scanId;
  final String productName;
  final DateTime scannedAt;
}
