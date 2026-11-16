class DashboardData {
  final String role;
  final String userName;
  final int areaId;
  final String dateNow;
  final Map<String, dynamic> stats;
  final List<dynamic> listItems; // recent_payments or work_orders or recent_registrations

  DashboardData({
    required this.role,
    required this.userName,
    required this.areaId,
    required this.dateNow,
    required this.stats,
    required this.listItems,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json['recent_payments'] != null) {
      items = json['recent_payments'];
    } else if (json['work_orders'] != null) {
      items = json['work_orders'];
    } else if (json['recent_registrations'] != null) {
      items = json['recent_registrations'];
    }

    return DashboardData(
      role: json['role'] ?? '',
      userName: json['user_name'] ?? '',
      areaId: json['area_id'] ?? 3,
      dateNow: json['date_now'] ?? '',
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      listItems: items,
    );
  }
}
