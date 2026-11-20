class UserModel {
  final int id;
  final String username;
  final String name;
  final String role;
  final int areaId;
  final String areaName;
  final String phone;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    required this.areaId,
    required this.areaName,
    required this.phone,
    this.avatarUrl,
  });

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isTechnician => role == 'teknisi';
  bool get isSales => role == 'sales';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      role: json['role'] ?? 'teknisi',
      areaId: json['area_id'] is int ? json['area_id'] : int.tryParse(json['area_id']?.toString() ?? '3') ?? 3,
      areaName: json['area_name'] ?? 'Sukorejo',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'role': role,
    'area_id': areaId,
    'area_name': areaName,
    'phone': phone,
    'avatar_url': avatarUrl,
  };
}
