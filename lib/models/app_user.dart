// ignore_for_file: public_member_api_docs, sort_constructors_first

class AppUser {
  final String id;
  final String? name;
  final String email;
  final bool isPro;
  final DateTime? nextProCheck;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isPro,
    required this.nextProCheck,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    bool? isPro,
    DateTime? nextProCheck,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isPro: isPro ?? this.isPro,
      nextProCheck: nextProCheck ?? this.nextProCheck,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'is_pro': isPro,
      'next_pro_check': nextProCheck?.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['username'] as String?,
      email: map['email'] as String,
      isPro: map['is_pro'] as bool? ?? false,
      nextProCheck: map['next_pro_check'] != null
          ? DateTime.tryParse(map['next_pro_check'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'AppUser(id: $id, name: $name, email: $email, isPro: $isPro, nextProCheck: $nextProCheck)';
  }

  @override
  bool operator ==(covariant AppUser other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.isPro == isPro &&
        other.nextProCheck == nextProCheck;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        isPro.hashCode ^
        nextProCheck.hashCode;
  }
}
