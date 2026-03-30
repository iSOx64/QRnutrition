import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/data/services/firebase_auth_service.dart';
import '../features/auth/data/services/user_firestore_service.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/profile/data/services/profile_firestore_service.dart';
import '../features/profile/data/repositories/profile_repository.dart';
import '../features/products/data/services/product_firestore_service.dart';
import '../features/products/data/services/product_storage_service.dart';
import '../features/products/data/repositories/product_repository.dart';
import '../features/scanner/data/services/scanner_service.dart';
import '../features/scanner/data/services/scanner_firestore_service.dart';
import '../features/scanner/data/repositories/scanner_repository.dart';
import '../features/openfoodfacts/data/services/openfoodfacts_service.dart';
import '../features/history/data/services/history_firestore_service.dart';
import '../features/history/data/repositories/history_repository.dart';
import '../features/dashboard/data/services/dashboard_service.dart';
import '../features/dashboard/data/repositories/dashboard_repository.dart';
import '../features/admin/data/services/admin_firestore_service.dart';
import '../features/admin/data/repositories/admin_repository.dart';
import '../features/settings/data/services/app_settings_service.dart';
import '../features/settings/data/repositories/app_settings_repository.dart';
import '../features/super_admin/data/services/super_admin_service.dart';
import '../features/super_admin/data/repositories/super_admin_repository.dart';
import 'router.dart';

class QRNutritionApp extends StatelessWidget {
  const QRNutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<UserFirestoreService>(
          create: (_) => UserFirestoreService(),
        ),
        ProxyProvider2<FirebaseAuthService, UserFirestoreService,
            AuthRepository>(
          update: (_, authService, userService, _) =>
              AuthRepository(authService, userService),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) =>
              AuthController(context.read<AuthRepository>())..init(),
        ),
        Provider<ProfileFirestoreService>(
          create: (_) => ProfileFirestoreService(),
        ),
        ProxyProvider<ProfileFirestoreService, ProfileRepository>(
          update: (_, service, __) => ProfileRepository(service),
        ),
        Provider<ProductFirestoreService>(
          create: (_) => ProductFirestoreService(),
        ),
        Provider<ProductStorageService>(
          create: (_) => ProductStorageService(),
        ),
        ProxyProvider2<ProductFirestoreService, ProductStorageService,
            ProductRepository>(
          update: (_, firestore, storage, __) =>
              ProductRepository(firestore, storage),
        ),
        Provider<ScannerService>(
          create: (_) => ScannerService(),
        ),
        Provider<ScannerFirestoreService>(
          create: (_) => ScannerFirestoreService(),
        ),
        Provider<OpenFoodFactsService>(
          create: (_) => OpenFoodFactsService(),
        ),
        ProxyProvider3<ScannerService, ScannerFirestoreService,
            OpenFoodFactsService, ScannerRepository>(
          update: (_, scanner, firestore, openFoodFacts, __) =>
              ScannerRepository(scanner, firestore, openFoodFacts),
        ),
        Provider<HistoryFirestoreService>(
          create: (_) => HistoryFirestoreService(),
        ),
        ProxyProvider<HistoryFirestoreService, HistoryRepository>(
          update: (_, service, __) => HistoryRepository(service),
        ),
        Provider<DashboardService>(
          create: (_) => DashboardService(),
        ),
        ProxyProvider<DashboardService, DashboardRepository>(
          update: (_, service, __) => DashboardRepository(service),
        ),
        Provider<AdminFirestoreService>(
          create: (_) => AdminFirestoreService(),
        ),
        ProxyProvider<AdminFirestoreService, AdminRepository>(
          update: (_, service, __) => AdminRepository(service),
        ),
        Provider<AppSettingsService>(
          create: (_) => AppSettingsService(),
        ),
        ProxyProvider<AppSettingsService, AppSettingsRepository>(
          update: (_, service, __) => AppSettingsRepository(service),
        ),
        Provider<SuperAdminService>(
          create: (_) => SuperAdminService(),
        ),
        ProxyProvider<SuperAdminService, SuperAdminRepository>(
          update: (_, service, __) => SuperAdminRepository(service),
        ),
      ],
      child: MaterialApp.router(
        title: 'QR Nutrition',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}


