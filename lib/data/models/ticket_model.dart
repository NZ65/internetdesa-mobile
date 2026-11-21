class TicketModel {
  final int id;
  final String ticketNumber;
  final int customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? mikrotikUsername;
  final double? latitude;
  final double? longitude;
  final String title;
  final String? description;
  final String status; // 'open', 'in_progress', 'resolved', 'closed'
  final String priority;
  final String? resolution;
  final String createdAt;

  TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.mikrotikUsername,
    this.latitude,
    this.longitude,
    required this.title,
    this.description,
    required this.status,
    this.priority = 'normal',
    this.resolution,
    required this.createdAt,
  });

  bool get isOpen => status == 'open' || status == 'in_progress';
  bool get isUrgent => priority.toLowerCase() == 'urgent' || priority.toLowerCase() == 'high';
  String get category => title;

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return TicketModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      ticketNumber: json['ticket_number'] ?? '#TK-${json['id']}',
      customerId: json['customer_id'] is int ? json['customer_id'] : int.tryParse(json['customer_id']?.toString() ?? '0') ?? 0,
      customerName: json['customer_name'] ?? 'Pelanggan',
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      mikrotikUsername: json['mikrotik_username'],
      latitude: parseCoord(json['latitude']),
      longitude: parseCoord(json['longitude']),
      title: json['title'] ?? 'Gangguan Layanan',
      description: json['description'],
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'normal',
      resolution: json['resolution'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
