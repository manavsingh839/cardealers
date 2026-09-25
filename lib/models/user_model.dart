class UserModel {
  final String id;
  final String email;
  final String role; // 'admin' | 'dealer'
  final String name;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isDealer => role == 'dealer';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return UserModel(
      id: id ?? map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'dealer',
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
