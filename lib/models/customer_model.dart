class CustomerModel {
  final int id;
  final String custId;
  final String name;
  final String phone;
  final String address;
  final String status; // active, isolated, suspended, inactive
  final String? mikrotikUsername;
  final String? ipAddress;
  final String? odpName;
  final String? odpPort;
  final double? latitude;
  final double? longitude;
  final String? packageName;
  final int? packagePrice;
  final int? packageId;
  final int? billingDate;
  final String? notes;
  final String? wifiSsid;
  final String? wifiPassword;
  final String? dropcoreLength;
  final String? onuSn;

  CustomerModel({
    required this.id,
    required this.custId,
    required this.name,
    required this.phone,
    required this.address,
    required this.status,
    this.mikrotikUsername,
    this.ipAddress,
    this.odpName,
    this.odpPort,
    this.latitude,
    this.longitude,
    this.packageName,
    this.packagePrice,
    this.packageId,
    this.billingDate,
    this.notes,
    this.wifiSsid,
    this.wifiPassword,
    this.dropcoreLength,
    this.onuSn,
  });

  bool get isIsolated => status == 'isolated' || status == 'suspended';
  bool get isActive => status == 'active';
  bool get isPasangBaru => status == 'pasang_baru' || status == 'pending';

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      custId: json['cust_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      mikrotikUsername: json['mikrotik_username']?.toString(),
      ipAddress: json['ip_address']?.toString(),
      odpName: json['odp_name']?.toString(),
      odpPort: json['odp_port']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      packageName: json['package_name']?.toString(),
      packagePrice: json['package_price'] != null ? int.tryParse(json['package_price'].toString()) : null,
      packageId: json['package_id'] != null ? int.tryParse(json['package_id'].toString()) : null,
      billingDate: json['billing_date'] != null ? int.tryParse(json['billing_date'].toString()) : 1,
      notes: json['notes']?.toString(),
      wifiSsid: json['wifi_ssid']?.toString(),
      wifiPassword: json['wifi_password']?.toString(),
      dropcoreLength: json['dropcore_length']?.toString() ?? json['dropcore']?.toString(),
      onuSn: json['onu_sn']?.toString() ?? json['modem_sn']?.toString() ?? json['sn']?.toString(),
    );
  }
}
