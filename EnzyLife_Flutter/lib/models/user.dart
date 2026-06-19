class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? postalCode;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.postalCode,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name']?.toString().trim() ?? '';
    final displayName = (rawName.isEmpty || rawName == '-') ? 'Pengguna Baru' : rawName;
    return UserModel(
      id: json['id'],
      name: displayName,
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      postalCode: json['postal_code'],
      avatar: json['avatar'],
    );
  }
}