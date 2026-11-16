class RegistrationModel {
  final int id;
  final String name;
  final String phone;
  final String? address;
  final int? packageId;
  final String? packageName;
  final int? packagePrice;
  final String status; // pending, survey, approved, installed, rejected
  final double? latitude;
  final double? longitude;
  final String? ktpPhoto;
  final String? housePhoto;
  final String? dropcoreLength;
  final String? createdBy;
  final String? createdAt;

  RegistrationModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.packageId,
    this.packageName,
    this.packagePrice,
    required this.status,
    this.latitude,
    this.longitude,
    this.ktpPhoto,
    this.housePhoto,
    this.dropcoreLength,
    this.createdBy,
    this.createdAt,
  });

  bool get isInstalled => status == 'installed';
  bool get isPending => status == 'pending';

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      packageId: json['package_id'] != null ? int.tryParse(json['package_id'].toString()) : null,
      packageName: json['package_name']?.toString(),
      packagePrice: json['package_price'] != null ? int.tryParse(json['package_price'].toString()) : null,
      status: json['status']?.toString() ?? 'pending',
      latitude: json['location_lat'] != null ? double.tryParse(json['location_lat'].toString()) : null,
      longitude: json['location_lng'] != null ? double.tryParse(json['location_lng'].toString()) : null,
      ktpPhoto: json['ktp_photo']?.toString(),
      housePhoto: json['house_photo']?.toString(),
      dropcoreLength: json['dropcore_length']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class PackageModel {
  final int id;
  final String name;
  final int price;
  final String? speedDown;
  final String? speedUp;
  final String? description;

  PackageModel({
    required this.id,
    required this.name,
    required this.price,
    this.speedDown,
    this.speedUp,
    this.description,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      speedDown: json['speed_down']?.toString(),
      speedUp: json['speed_up']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
