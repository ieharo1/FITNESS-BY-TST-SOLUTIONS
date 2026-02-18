import 'package:flutter/material.dart';

class BmiHistoryModel {
  final String id;
  final String userId;
  final double bmi;
  final double weight;
  final double height;
  final DateTime date;

  BmiHistoryModel({
    required this.id,
    required this.userId,
    required this.bmi,
    required this.weight,
    required this.height,
    required this.date,
  });

  factory BmiHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return BmiHistoryModel(
      id: id,
      userId: map['userId'] ?? '',
      bmi: (map['bmi'] ?? 0.0).toDouble(),
      weight: (map['weight'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bmi': bmi,
      'weight': weight,
      'height': height,
      'date': date,
    };
  }

  BmiHistoryModel copyWith({
    String? id,
    String? userId,
    double? bmi,
    double? weight,
    double? height,
    DateTime? date,
  }) {
    return BmiHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bmi: bmi ?? this.bmi,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      date: date ?? this.date,
    );
  }

  String get category {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    if (bmi < 35) return 'Obesidad grado I';
    if (bmi < 40) return 'Obesidad grado II';
    return 'Obesidad grado III';
  }

  Color get color {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}
