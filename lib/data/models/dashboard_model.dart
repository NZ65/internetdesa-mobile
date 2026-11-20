class DashboardModel {
  final String role;
  final String userName;
  final int areaId;
  final String dateNow;
  final Map<String, dynamic> stats;
  final Map<String, dynamic>? mikrotik;
  final Map<String, dynamic>? olt;
  final List<dynamic> recentItems;

  DashboardModel({
    required this.role,
    required this.userName,
    required this.areaId,
    required this.dateNow,
    required this.stats,
    this.mikrotik,
    this.olt,
    required this.recentItems,
  });

  // Safe stat getters
  num get saldoKas => stats['saldo_tersisa'] ?? 0;
  num get sisaModal => stats['sisa_modal'] ?? 0;
  num get sisaKasOps => stats['sisa_kas_ops'] ?? 0;
  num get totalRevenue => stats['month_revenue'] ?? 0;
  num get totalExpense => stats['month_expense'] ?? 0;
  num get unpaidAmount => stats['unpaid_invoices_amount'] ?? 0;
  int get unpaidCount => stats['unpaid_invoices_count'] ?? 0;
  int get totalCustomers => stats['total_customers'] ?? 0;
  int get activeCustomers => stats['active_customers'] ?? 0;
  int get isolatedCustomers => stats['isolated_customers'] ?? 0;
  int get pendingRegistrations => stats['pending_registrations'] ?? 0;
  int get openTickets => stats['open_tickets'] ?? stats['open_tickets_count'] ?? 0;

  // MikroTik getters
  bool get isMikrotikOnline => mikrotik?['connected'] == true;
  String get wanRx => mikrotik?['wan_rx'] ?? '0 bps';
  String get wanTx => mikrotik?['wan_tx'] ?? '0 bps';
  int get activePppoe => mikrotik?['active_pppoe'] ?? activeCustomers;
  num get cpuLoad => mikrotik?['cpu_load'] ?? 0;
  String get mikrotikUptime => mikrotik?['uptime'] ?? '-';

  // OLT getters
  bool get isOltOnline => olt?['connected'] == true;
  int get totalOnus => olt?['total_onus'] ?? totalCustomers;
  int get onlineOnus => olt?['online_onus'] ?? activeCustomers;
  int get losOnus => olt?['los_onus'] ?? 0;
  String get avgRxPower => olt?['avg_rx_power'] ?? '-18.5 dBm';

  factory DashboardModel.fromJson(Map<String, dynamic> raw) {
    final Map<String, dynamic> json = (raw['data'] is Map)
        ? Map<String, dynamic>.from(raw['data'])
        : raw;

    List<dynamic> items = [];
    if (json['recent_payments'] is List) {
      items = json['recent_payments'];
    } else if (json['work_orders'] is List) {
      items = json['work_orders'];
    } else if (json['recent_registrations'] is List) {
      items = json['recent_registrations'];
    }

    return DashboardModel(
      role: json['role'] ?? '',
      userName: json['user_name'] ?? '',
      areaId: json['area_id'] ?? 3,
      dateNow: json['date_now'] ?? '',
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      mikrotik: json['mikrotik'] != null ? Map<String, dynamic>.from(json['mikrotik']) : null,
      olt: json['olt'] != null ? Map<String, dynamic>.from(json['olt']) : null,
      recentItems: items,
    );
  }
}
