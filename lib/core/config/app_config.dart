class AppConfig {
  static const String appName = 'Internet Desa';
  static const String appVersion = '1.6.0';
  static const int appVersionCode = 17;

  // Production Server Base URL
  static const String defaultBaseUrl = 'https://internetdesaku.my.id';

  // Local Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyBaseUrl = 'custom_base_url';
  static const String keySoundEnabled = 'sound_enabled';

  // GitHub OAuth Configuration
  static const String githubClientId = 'Ov23liEPEAZVx5HsgxOn';
  static const String epGithubAuth = '/api/mobile/auth/github';
  static const String epGithubUrl = '/api/mobile/auth/github/url';

  // API Endpoints
  static const String epVersion = '/api/mobile/version';
  static const String epLogin = '/api/mobile/auth/login';
  static const String epProfile = '/api/mobile/auth/profile';
  static const String epChangePassword = '/api/mobile/auth/change-password';
  static const String epDashboard = '/api/mobile/dashboard';
  static const String epCustomers = '/api/mobile/customers';
  static const String epInvoices = '/api/mobile/invoices';
  static const String epExpenses = '/api/mobile/expenses';
  static const String epOdp = '/api/mobile/odp';
  static const String epPackages = '/api/mobile/packages';

  // Technician Endpoints
  static const String epTechnicianTickets = '/api/mobile/technician/tickets';
  static const String epQuickReboot = '/api/mobile/technician/quick-reboot';
  static const String epQuickWifi = '/api/mobile/technician/quick-wifi';

  // Sales Endpoints
  static const String epSalesPackages = '/api/mobile/sales/packages';
  static const String epSalesRegistrations = '/api/mobile/sales/my-registrations';
  static const String epSalesRegister = '/api/mobile/sales/register';

  // Network Tools Endpoints
  static const String epToolsOverview = '/api/mobile/tools/overview';
  static const String epToolsPing = '/api/mobile/tools/ping';
  static const String epToolsKick = '/api/mobile/tools/kick-pppoe';
  static const String epToolsLos = '/api/mobile/tools/olt-los';
  static const String epToolsIsolate = '/api/mobile/tools/toggle-isolate';
}
