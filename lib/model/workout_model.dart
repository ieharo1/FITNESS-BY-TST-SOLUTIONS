class WorkoutModel {
  final String id;
  final String userId;
  final DateTime date;
  final String type;
  final List<Map<String, dynamic>> exercises;
  final DateTime createdAt;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.exercises,
    required this.createdAt,
  });

  factory WorkoutModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutModel(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
      type: map['type'] ?? '',
      exercises: List<Map<String, dynamic>>.from(map['exercises'] ?? []),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'type': type,
      'exercises': exercises,
      'createdAt': createdAt,
    };
  }

  WorkoutModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? type,
    List<Map<String, dynamic>>? exercises,
    DateTime? createdAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      type: type ?? this.type,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ExerciseModel {
  final String name;
  final int sets;
  final int reps;
  final double weight;

  ExerciseModel({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
    );
  }
}
