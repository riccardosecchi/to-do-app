/// Represents an authenticated user in the application's domain layer.
class AppUser {
  final String id;
  final String email;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() => 'AppUser(id: $id, email: $email)';
}
