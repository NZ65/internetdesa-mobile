class OdpModel {
  final int id;
  final String name;
  final String? odcParent;
  final String? oltPort;
  final int totalPorts;
  final int usedPorts;
  final int availablePorts;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? splitterType;
  final String status;
  final String? notes;

  OdpModel({
    required this.id,
    required this.name,
    this.odcParent,
    this.oltPort,
    this.totalPorts = 8,
    this.usedPorts = 0,
    this.availablePorts = 8,
    this.latitude,
    this.longitude,
    this.address,
    this.splitterType,
    this.status = 'active',
    this.notes,
  });

  bool get isFull => availablePorts <= 0;
  double get usagePercent => totalPorts > 0 ? (usedPorts / totalPorts).clamp(0.0, 1.0) : 0.0;

  factory OdpModel.fromJson(Map<String, dynamic> json) {
    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return OdpModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      odcParent: json['odc_parent'],
      oltPort: json['olt_port']?.toString(),
      totalPorts: json['total_ports'] is int ? json['total_ports'] : int.tryParse(json['total_ports']?.toString() ?? '8') ?? 8,
      usedPorts: json['used_ports'] is int ? json['used_ports'] : int.tryParse(json['used_ports']?.toString() ?? '0') ?? 0,
      availablePorts: json['available_ports'] is int ? json['available_ports'] : int.tryParse(json['available_ports']?.toString() ?? '8') ?? 8,
      latitude: parseCoord(json['latitude']),
      longitude: parseCoord(json['longitude']),
      address: json['address'],
      splitterType: json['splitter_type'],
      status: json['status'] ?? 'active',
      notes: json['notes'],
    );
  }
}
