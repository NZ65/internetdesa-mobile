class RegistrationModel {
  final int id;
  final String name;
  final String phone;
  final String address;
  final int packageId;
  final String? packageName;
  final num? packagePrice;
  final String status;
  final double? latitude;
  final double? longitude;
  final String? ktpPhoto;
  final String? housePhoto;
  final String? createdBy;
  final String createdAt;

  RegistrationModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.packageId,
    this.packageName,
    this.packagePrice,
    required this.status,
    this.latitude,
    this.longitude,
    this.ktpPhoto,
    this.housePhoto,
    this.createdBy,
    required this.createdAt,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return RegistrationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      packageId: json['package_id'] is int ? json['package_id'] : int.tryParse(json['package_id']?.toString() ?? '1') ?? 1,
      packageName: json['package_name'],
      packagePrice: json['package_price'],
      status: json['status'] ?? 'pending',
      latitude: parseCoord(json['latitude'] ?? json['location_lat']),
      longitude: parseCoord(json['longitude'] ?? json['location_lng']),
      ktpPhoto: json['ktp_photo'],
      housePhoto: json['house_photo'],
      createdBy: json['created_by'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
