import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/workout_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../../model/workout_model.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<ExerciseModel> _exercises = [];
  bool _isLoading = false;

  final List<String> _workoutTypes = [
    'Entrenamiento de Fuerza',
    'Cardio',
    'HIIT',
    'Yoga',
    'CrossFit',
    'Natación',
    'Correr',
    'Ciclismo',
    'Otro',
  ];

  final List<String> _workoutTypesEn = [
    'Strength Training',
    'Cardio',
    'HIIT',
    'Yoga',
    'CrossFit',
    'Swimming',
    'Running',
    'Cycling',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUserId != null) {
        context.read<WorkoutViewModel>().loadWorkouts(authViewModel.currentUserId!);
      }
    });
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        onAdd: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
        },
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      if (_exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor agrega al menos un ejercicio'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final workoutViewModel = context.read<WorkoutViewModel>();
      final success = await workoutViewModel.addWorkout(
        type: _typeController.text,
        date: _selectedDate,
        exercises: _exercises.map((e) => e.toMap()).toList(),
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Entrenamiento guardado exitosamente!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(workoutViewModel.errorMessage ?? 'Error al guardar'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Entrenamiento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles del Entrenamiento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _typeController.text.isEmpty ? null : _typeController.text,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Entrenamiento',
                          prefixIcon: Icon(Icons.fitness_center),
                        ),
                        items: _workoutTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _typeController.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona un tipo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha y Hora',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy - HH:mm', 'es_ES').format(_selectedDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ejercicios',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addExercise,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_exercises.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No hay ejercicios agregados',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _exercises[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '${exercise.sets} series x ${exercise.reps} repeticiones${exercise.weight > 0 ? ' - ${exercise.weight} kg' : ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                                    onPressed: () => _removeExercise(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveWorkout,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar Entrenamiento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddExerciseDialog extends StatefulWidget {
  final Function(ExerciseModel) onAdd;

  const _AddExerciseDialog({required this.onAdd});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Ejercicio'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Ejercicio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Series'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Repeticiones'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'Opcional',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final exercise = ExerciseModel(
                name: _nameController.text,
                sets: int.parse(_setsController.text),
                reps: int.parse(_repsController.text),
                weight: double.tryParse(_weightController.text) ?? 0.0,
              );
              widget.onAdd(exercise);
              Navigator.pop(context);
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
