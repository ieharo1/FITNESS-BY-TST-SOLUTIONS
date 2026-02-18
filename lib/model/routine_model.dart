import '../model/goals_model.dart';

class RoutineModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<RoutineExercise> exercises;
  final int estimatedMinutes;
  final String difficulty;
  final List<int> weekDays;
  final DateTime createdAt;
  final bool isActive;
  final String? imageUrl;

  RoutineModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.exercises,
    this.estimatedMinutes = 60,
    this.difficulty = 'intermediate',
    this.weekDays = const [1, 3, 5],
    required this.createdAt,
    this.isActive = true,
    this.imageUrl,
  });

  factory RoutineModel.fromMap(Map<String, dynamic> map, String id) {
    return RoutineModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      exercises: (map['exercises'] as List<dynamic>?)
          ?.map((e) => RoutineExercise.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      estimatedMinutes: map['estimatedMinutes'] ?? 60,
      difficulty: map['difficulty'] ?? 'intermediate',
      weekDays: List<int>.from(map['weekDays'] ?? [1, 3, 5]),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'estimatedMinutes': estimatedMinutes,
      'difficulty': difficulty,
      'weekDays': weekDays,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  RoutineModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<RoutineExercise>? exercises,
    int? estimatedMinutes,
    String? difficulty,
    List<int>? weekDays,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      weekDays: weekDays ?? this.weekDays,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class RoutineExercise {
  final String name;
  final int sets;
  final int reps;
  final int? durationSeconds;
  final double? weight;
  final int restSeconds;
  final String? notes;

  RoutineExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.durationSeconds,
    this.weight,
    this.restSeconds = 60,
    this.notes,
  });

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 10,
      durationSeconds: map['durationSeconds'],
      weight: (map['weight'] as num?)?.toDouble(),
      restSeconds: map['restSeconds'] ?? 60,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'weight': weight,
      'restSeconds': restSeconds,
      'notes': notes,
    };
  }
}

class NutritionModel {
  final String id;
  final String userId;
  final double dailyCalories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final int mealsPerDay;
  final DateTime createdAt;

  NutritionModel({
    required this.id,
    required this.userId,
    this.dailyCalories = 2000,
    this.proteinGrams = 150,
    this.carbsGrams = 200,
    this.fatGrams = 65,
    this.mealsPerDay = 3,
    required this.createdAt,
  });

  factory NutritionModel.fromMap(Map<String, dynamic> map, String id) {
    return NutritionModel(
      id: id,
      userId: map['userId'] ?? '',
      dailyCalories: (map['dailyCalories'] ?? 2000).toDouble(),
      proteinGrams: (map['proteinGrams'] ?? 150).toDouble(),
      carbsGrams: (map['carbsGrams'] ?? 200).toDouble(),
      fatGrams: (map['fatGrams'] ?? 65).toDouble(),
      mealsPerDay: map['mealsPerDay'] ?? 3,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dailyCalories': dailyCalories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'mealsPerDay': mealsPerDay,
      'createdAt': createdAt,
    };
  }

  NutritionModel copyWith({
    String? id,
    String? userId,
    double? dailyCalories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    int? mealsPerDay,
    DateTime? createdAt,
  }) {
    return NutritionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
