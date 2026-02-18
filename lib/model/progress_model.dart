class ProgressModel {
  final String id;
  final String userId;
  final double weight;
  final String? photoUrl;
  final DateTime date;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.weight,
    this.photoUrl,
    required this.date,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map, String id) {
    return ProgressModel(
      id: id,
      userId: map['userId'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      photoUrl: map['photoUrl'],
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'weight': weight,
      'photoUrl': photoUrl,
      'date': date,
    };
  }

  ProgressModel copyWith({
    String? id,
    String? userId,
    double? weight,
    String? photoUrl,
    DateTime? date,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
      date: date ?? this.date,
    );
  }
}
