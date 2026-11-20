import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/invoice_provider.dart';
import 'presentation/providers/sales_provider.dart';
import 'presentation/providers/technician_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(const InternetDesaApp());
}

class InternetDesaApp extends StatelessWidget {
  const InternetDesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => TechnicianProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
