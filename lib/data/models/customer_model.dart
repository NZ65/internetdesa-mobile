class CustomerModel {
  final int id;
  final String custId;
  final String name;
  final String phone;
  final String address;
  final String status;
  final String onlineStatus;
  final String mikrotikUsername;
  final String? ipAddress;
  final String? odpName;
  final String? odpPort;
  final String? wifiSsid;
  final String? wifiPassword;
  final String? onuSn;
  final String? onuId;
  final String? oltPort;
  final double? latitude;
  final double? longitude;
  final String? packageName;
  final num? packagePrice;
  final int? billingDate;
  final int unpaidCount;
  final num unpaidAmount;
  final num downloadBytes;
  final num uploadBytes;

  CustomerModel({
    required this.id,
    required this.custId,
    required this.name,
    required this.phone,
    required this.address,
    required this.status,
    required this.onlineStatus,
    required this.mikrotikUsername,
    this.ipAddress,
    this.odpName,
    this.odpPort,
    this.wifiSsid,
    this.wifiPassword,
    this.onuSn,
    this.onuId,
    this.oltPort,
    this.latitude,
    this.longitude,
    this.packageName,
    this.packagePrice,
    this.billingDate,
    this.unpaidCount = 0,
    this.unpaidAmount = 0,
    this.downloadBytes = 0,
    this.uploadBytes = 0,
  });

  bool get isOnline => onlineStatus == 'online' || status == 'active';
  bool get isIsolated => status == 'isolated' || status == 'suspended';
  bool get hasUnpaid => unpaidCount > 0;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      custId: json['cust_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? 'active',
      onlineStatus: json['online_status'] ?? json['status'] ?? 'offline',
      mikrotikUsername: json['mikrotik_username'] ?? '',
      ipAddress: json['ip_address'],
      odpName: json['odp_name'],
      odpPort: json['odp_port']?.toString(),
      wifiSsid: json['wifi_ssid'],
      wifiPassword: json['wifi_password'],
      onuSn: json['onu_sn'],
      onuId: json['onu_id']?.toString(),
      oltPort: json['olt_port']?.toString(),
      latitude: parseCoord(json['latitude'] ?? json['location_lat']),
      longitude: parseCoord(json['longitude'] ?? json['location_lng']),
      packageName: json['package_name'],
      packagePrice: json['package_price'],
      billingDate: json['billing_date'] is int ? json['billing_date'] : int.tryParse(json['billing_date']?.toString() ?? ''),
      unpaidCount: json['unpaid_invoices_count'] is int ? json['unpaid_invoices_count'] : int.tryParse(json['unpaid_invoices_count']?.toString() ?? '0') ?? 0,
      unpaidAmount: json['unpaid_amount'] is num ? json['unpaid_amount'] : num.tryParse(json['unpaid_amount']?.toString() ?? '0') ?? 0,
      downloadBytes: json['download_bytes'] ?? json['current_month_download'] ?? 0,
      uploadBytes: json['upload_bytes'] ?? json['current_month_upload'] ?? 0,
    );
  }
}
