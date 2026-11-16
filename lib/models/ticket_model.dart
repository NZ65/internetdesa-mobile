class TicketModel {
  final int id;
  final String title;
  final String? description;
  final String status; // open, in_progress, resolved, closed
  final String priority; // low, normal, high, critical
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? mikrotikUsername;
  final double? latitude;
  final double? longitude;
  final String? createdAt;
  final String? resolution;

  TicketModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.priority = 'normal',
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.mikrotikUsername,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.resolution,
  });

  bool get isOpen => status == 'open' || status == 'in_progress';
  bool get isResolved => status == 'resolved' || status == 'closed';

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? 'Gangguan Layanan',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'normal',
      customerId: json['customer_id'] != null ? int.tryParse(json['customer_id'].toString()) : null,
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      customerAddress: json['customer_address']?.toString(),
      mikrotikUsername: json['mikrotik_username']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      createdAt: json['created_at']?.toString(),
      resolution: json['resolution']?.toString(),
    );
  }
}
