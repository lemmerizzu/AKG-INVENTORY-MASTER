enum UserRole { admin, manager, warehouse, driver }

/// User profile — linked to Supabase `auth.users` via `user_profiles` table.
class UserProfile {
  final String id;
  final String displayName;
  final UserRole role;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.role,
    this.phone,
    this.isActive = true,
    this.createdAt,
  });

  static const _roleMap = {
    'admin': UserRole.admin,
    'manager': UserRole.manager,
    'warehouse': UserRole.warehouse,
    'driver': UserRole.driver,
  };
  static const _roleRev = {
    UserRole.admin: 'admin',
    UserRole.manager: 'manager',
    UserRole.warehouse: 'warehouse',
    UserRole.driver: 'driver',
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String,
        role: _roleMap[json['role']] ?? UserRole.warehouse,
        phone: json['phone'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'role': _roleRev[role],
        'phone': phone,
        'is_active': isActive,
      };
}
