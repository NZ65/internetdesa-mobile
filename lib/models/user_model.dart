class UserModel {
  final int id;
  final String username;
  final String name;
  final String role; // 'admin', 'superadmin', 'teknisi', 'sales'
  final int areaId;
  final String areaName;
  final String phone;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    required this.areaId,
    required this.areaName,
    this.phone = '',
  });

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isTechnician => role == 'teknisi' || isAdmin;
  bool get isSales => role == 'sales' || isAdmin;

  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return 'Super Admin';
      case 'admin':
        return 'Administrator';
      case 'teknisi':
        return 'Teknisi Lapangan';
      case 'sales':
        return 'Sales & Pemasaran';
      default:
        return role.toUpperCase();
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      role: (json['role'] ?? 'teknisi').toString().toLowerCase(),
      areaId: json['area_id'] is int ? json['area_id'] : int.tryParse(json['area_id']?.toString() ?? '3') ?? 3,
      areaName: json['area_name'] ?? 'Sukorejo',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'area_id': areaId,
      'area_name': areaName,
      'phone': phone,
    };
  }
}
