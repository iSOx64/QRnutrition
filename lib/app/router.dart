import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/role_utils.dart';
import '../features/auth/data/models/app_user_model.dart';
import '../features/auth/presentation/pages/auth_gate_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/verify_email_page.dart';
import '../features/auth/presentation/pages/welcome_page.dart';
import '../features/home/presentation/pages/user_home_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/profile/presentation/pages/user_profile_page.dart';
import '../features/products/data/models/product_model.dart';
import '../features/products/presentation/pages/product_details_page.dart';
import '../features/products/presentation/pages/product_search_page.dart';
import '../features/scanner/presentation/pages/scanner_page.dart';
import '../features/history/presentation/pages/scan_history_page.dart';
import '../features/dashboard/presentation/pages/nutrition_dashboard_page.dart';
import '../features/admin/presentation/pages/admin_home_page.dart';
import '../features/admin/presentation/pages/admin_products_list_page.dart';
import '../features/admin/presentation/pages/add_product_page.dart';
import '../features/admin/presentation/pages/edit_product_page.dart';
import '../features/admin/presentation/pages/admin_statistics_page.dart';
import '../features/admin/presentation/pages/admin_logs_page.dart';
import '../features/super_admin/presentation/pages/super_admin_home_page.dart';
import '../features/super_admin/presentation/pages/manage_admins_page.dart';
import '../features/super_admin/presentation/pages/system_logs_page.dart';
import '../features/settings/presentation/pages/global_settings_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

enum AppRoute {
  authGate,
  welcome,
  login,
  adminLogin,
  superAdminLogin,
  register,
  verifyEmail,
  forgotPassword,
  home,
  userHome,
  userProfile,
  editProfile,
  scanner,
  productSearch,
  productDetails,
  scanHistory,
  nutritionDashboard,
  adminHome,
  adminProducts,
  addProduct,
  editProduct,
  adminStatistics,
  adminLogs,
  superAdminHome,
  manageAdmins,
  globalSettings,
  systemLogs,
}

extension AppRoutePath on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.authGate:
        return '/';
      case AppRoute.welcome:
        return '/welcome';
      case AppRoute.login:
        return '/login';
      case AppRoute.adminLogin:
        return '/admin/login';
      case AppRoute.superAdminLogin:
        return '/super-admin/login';
      case AppRoute.register:
        return '/register';
      case AppRoute.verifyEmail:
        return '/verify-email';
      case AppRoute.forgotPassword:
        return '/forgot-password';
      case AppRoute.home:
        return '/home';
      case AppRoute.userHome:
        return '/user/home';
      case AppRoute.userProfile:
        return '/user/profile';
      case AppRoute.editProfile:
        return '/user/profile/edit';
      case AppRoute.scanner:
        return '/scanner';
      case AppRoute.productSearch:
        return '/products/search';
      case AppRoute.productDetails:
        return '/products/details';
      case AppRoute.scanHistory:
        return '/history';
      case AppRoute.nutritionDashboard:
        return '/dashboard';
      case AppRoute.adminHome:
        return '/admin/home';
      case AppRoute.adminProducts:
        return '/admin/products';
      case AppRoute.addProduct:
        return '/admin/products/add';
      case AppRoute.editProduct:
        return '/admin/products/edit';
      case AppRoute.adminStatistics:
        return '/admin/statistics';
      case AppRoute.adminLogs:
        return '/admin/logs';
      case AppRoute.superAdminHome:
        return '/super-admin/home';
      case AppRoute.manageAdmins:
        return '/super-admin/manage-admins';
      case AppRoute.globalSettings:
        return '/super-admin/settings';
      case AppRoute.systemLogs:
        return '/super-admin/logs';
    }
  }
}

String roleHomePath(AppUser? user) {
  if (user == null) {
    return AppRoute.welcome.path;
  }
  if (isSuperAdmin(user)) {
    return AppRoute.superAdminHome.path;
  }
  if (isAdmin(user)) {
    return AppRoute.adminHome.path;
  }
  return AppRoute.userHome.path;
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoute.authGate.path,
  routes: [
    GoRoute(
      path: AppRoute.authGate.path,
      name: AppRoute.authGate.name,
      builder: (context, state) => const AuthGatePage(),
    ),
    GoRoute(
      path: AppRoute.welcome.path,
      name: AppRoute.welcome.name,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: AppRoute.login.path,
      name: AppRoute.login.name,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoute.adminLogin.path,
      name: AppRoute.adminLogin.name,
      builder: (context, state) =>
          const LoginPage(target: LoginTarget.admin),
    ),
    GoRoute(
      path: AppRoute.superAdminLogin.path,
      name: AppRoute.superAdminLogin.name,
      builder: (context, state) =>
          const LoginPage(target: LoginTarget.superAdmin),
    ),
    GoRoute(
      path: AppRoute.register.path,
      name: AppRoute.register.name,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoute.verifyEmail.path,
      name: AppRoute.verifyEmail.name,
      builder: (context, state) => const VerifyEmailPage(),
    ),
    GoRoute(
      path: AppRoute.forgotPassword.path,
      name: AppRoute.forgotPassword.name,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoute.home.path,
      name: AppRoute.home.name,
      builder: (context, state) => const AuthGatePage(),
    ),
    GoRoute(
      path: AppRoute.userHome.path,
      name: AppRoute.userHome.name,
      builder: (context, state) => const UserHomePage(),
    ),
    GoRoute(
      path: AppRoute.userProfile.path,
      name: AppRoute.userProfile.name,
      builder: (context, state) => const UserProfilePage(),
    ),
    GoRoute(
      path: AppRoute.editProfile.path,
      name: AppRoute.editProfile.name,
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: AppRoute.scanner.path,
      name: AppRoute.scanner.name,
      builder: (context, state) {
        final openGallery =
            state.extra is bool && (state.extra as bool) == true;
        return ScannerPage(openGalleryOnStart: openGallery);
      },
    ),
    GoRoute(
      path: AppRoute.productSearch.path,
      name: AppRoute.productSearch.name,
      builder: (context, state) => const ProductSearchPage(),
    ),
    GoRoute(
      path: AppRoute.productDetails.path,
      name: AppRoute.productDetails.name,
      builder: (context, state) {
        final product = state.extra as Product?;
        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('Produit introuvable')),
          );
        }
        return ProductDetailsPage(product: product);
      },
    ),
    GoRoute(
      path: AppRoute.scanHistory.path,
      name: AppRoute.scanHistory.name,
      builder: (context, state) => const ScanHistoryPage(),
    ),
    GoRoute(
      path: AppRoute.nutritionDashboard.path,
      name: AppRoute.nutritionDashboard.name,
      builder: (context, state) => const NutritionDashboardPage(),
    ),
    GoRoute(
      path: AppRoute.adminHome.path,
      name: AppRoute.adminHome.name,
      builder: (context, state) => const AdminHomePage(),
    ),
    GoRoute(
      path: AppRoute.adminProducts.path,
      name: AppRoute.adminProducts.name,
      builder: (context, state) => const AdminProductsListPage(),
    ),
    GoRoute(
      path: AppRoute.addProduct.path,
      name: AppRoute.addProduct.name,
      builder: (context, state) => const AddProductPage(),
    ),
    GoRoute(
      path: AppRoute.editProduct.path,
      name: AppRoute.editProduct.name,
      builder: (context, state) {
        final product = state.extra as Product?;
        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('Produit introuvable')),
          );
        }
        return EditProductPage(product: product);
      },
    ),
    GoRoute(
      path: AppRoute.adminStatistics.path,
      name: AppRoute.adminStatistics.name,
      builder: (context, state) => const AdminStatisticsPage(),
    ),
    GoRoute(
      path: AppRoute.adminLogs.path,
      name: AppRoute.adminLogs.name,
      builder: (context, state) => const AdminLogsPage(),
    ),
    GoRoute(
      path: AppRoute.superAdminHome.path,
      name: AppRoute.superAdminHome.name,
      builder: (context, state) => const SuperAdminHomePage(),
    ),
    GoRoute(
      path: AppRoute.manageAdmins.path,
      name: AppRoute.manageAdmins.name,
      builder: (context, state) => const ManageAdminsPage(),
    ),
    GoRoute(
      path: AppRoute.globalSettings.path,
      name: AppRoute.globalSettings.name,
      builder: (context, state) => const GlobalSettingsPage(),
    ),
    GoRoute(
      path: AppRoute.systemLogs.path,
      name: AppRoute.systemLogs.name,
      builder: (context, state) => const SystemLogsPage(),
    ),
  ],
);


