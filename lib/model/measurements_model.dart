class MeasurementsModel {
  final String id;
  final String userId;
  final double weight;
  final double? waist;
  final double? chest;
  final double? arm;
  final double? leg;
  final double? hips;
  final double? shoulders;
  final String? photoUrl;
  final DateTime date;
  final String? notes;

  MeasurementsModel({
    required this.id,
    required this.userId,
    required this.weight,
    this.waist,
    this.chest,
    this.arm,
    this.leg,
    this.hips,
    this.shoulders,
    this.photoUrl,
    required this.date,
    this.notes,
  });

  factory MeasurementsModel.fromMap(Map<String, dynamic> map, String id) {
    return MeasurementsModel(
      id: id,
      userId: map['userId'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      waist: (map['waist'] as num?)?.toDouble(),
      chest: (map['chest'] as num?)?.toDouble(),
      arm: (map['arm'] as num?)?.toDouble(),
      leg: (map['leg'] as num?)?.toDouble(),
      hips: (map['hips'] as num?)?.toDouble(),
      shoulders: (map['shoulders'] as num?)?.toDouble(),
      photoUrl: map['photoUrl'],
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'weight': weight,
      'waist': waist,
      'chest': chest,
      'arm': arm,
      'leg': leg,
      'hips': hips,
      'shoulders': shoulders,
      'photoUrl': photoUrl,
      'date': date,
      'notes': notes,
    };
  }

  MeasurementsModel copyWith({
    String? id,
    String? userId,
    double? weight,
    double? waist,
    double? chest,
    double? arm,
    double? leg,
    double? hips,
    double? shoulders,
    String? photoUrl,
    DateTime? date,
    String? notes,
  }) {
    return MeasurementsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      waist: waist ?? this.waist,
      chest: chest ?? this.chest,
      arm: arm ?? this.arm,
      leg: leg ?? this.leg,
      hips: hips ?? this.hips,
      shoulders: shoulders ?? this.shoulders,
      photoUrl: photoUrl ?? this.photoUrl,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
