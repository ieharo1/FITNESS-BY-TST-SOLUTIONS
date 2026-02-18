class UserModel {
  final String id;
  final String name;
  final String email;
  final double weight;
  final double height;
  final String goal;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.weight = 0.0,
    this.height = 0.0,
    this.goal = '',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      goal: map['goal'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'weight': weight,
      'height': height,
      'goal': goal,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    double? weight,
    double? height,
    String? goal,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
