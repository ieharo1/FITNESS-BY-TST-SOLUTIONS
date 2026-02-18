import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../../model/routine_model.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUserId != null) {
        context.read<RoutineViewModel>().loadRoutines(authViewModel.currentUserId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<RoutineViewModel>(
        builder: (context, routineViewModel, child) {
          if (routineViewModel.state == RoutineLoadingState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final routines = routineViewModel.routines;
          
          if (routines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No hay rutinas creadas'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateRoutineDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Rutina'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _buildRoutineCard(routine, routineViewModel);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRoutineDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Rutina'),
      ),
    );
  }

  Widget _buildRoutineCard(RoutineModel routine, RoutineViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRoutineDetails(routine),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      routine.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, viewModel, routine.id);
                      } else if (value == 'edit') {
                        _showEditRoutineDialog(routine);
                      }
                    },
                  ),
                ],
              ),
              if (routine.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  routine.description!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.timer, '${routine.estimatedMinutes} min'),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.fitness_center, '${routine.exercises.length} ejer.'),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.calendar_today, _formatWeekDays(routine.weekDays)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _formatWeekDays(List<int> days) {
    const daysMap = {1: 'L', 2: 'M', 3: 'X', 4: 'J', 5: 'V', 6: 'S', 7: 'D'};
    return days.map((d) => daysMap[d] ?? '').join(', ');
  }

  void _showRoutineDetails(RoutineModel routine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(routine.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              if (routine.description != null) ...[
                const SizedBox(height: 8),
                Text(routine.description!, style: TextStyle(color: Colors.grey.shade600)),
              ],
              const SizedBox(height: 16),
              Text('Ejercicios (${routine.exercises.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: routine.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = routine.exercises[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(exercise.name),
                      subtitle: Text('${exercise.sets} series x ${exercise.reps} rep. • ${exercise.restSeconds}s descanso'),
                      trailing: exercise.weight != null ? Text('${exercise.weight} kg') : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateRoutineDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final exercises = <RoutineExercise>[];
    final selectedDays = <int>{1, 3, 5};
    File? selectedImage;
    final ImagePicker _picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nueva Rutina', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre de la rutina'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                ),
                const SizedBox(height: 16),
                const Text('Selecciona los días de la semana:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDayChip(1, 'Lun', selectedDays, setModalState),
                    _buildDayChip(2, 'Mar', selectedDays, setModalState),
                    _buildDayChip(3, 'Mié', selectedDays, setModalState),
                    _buildDayChip(4, 'Jue', selectedDays, setModalState),
                    _buildDayChip(5, 'Vie', selectedDays, setModalState),
                    _buildDayChip(6, 'Sáb', selectedDays, setModalState),
                    _buildDayChip(7, 'Dom', selectedDays, setModalState),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Imagen de la rutina (opcional):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          selectedImage = File(image.path);
                          setModalState(() {});
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          image: selectedImage != null
                              ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, color: Colors.grey.shade600),
                                  const SizedBox(height: 4),
                                  Text('Agregar', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (selectedImage != null)
                      TextButton(
                        onPressed: () {
                          selectedImage = null;
                          setModalState(() {});
                        },
                        child: const Text('Quitar'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ejercicios (${exercises.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        final nameController = TextEditingController();
                        final setsController = TextEditingController(text: '3');
                        final repsController = TextEditingController(text: '10');
                        final restController = TextEditingController(text: '60');
                        
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Agregar Ejercicio'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: TextField(controller: setsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Series'))),
                                    const SizedBox(width: 8),
                                    Expanded(child: TextField(controller: repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps'))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(controller: restController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Descanso (seg)')),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                              ElevatedButton(
                                onPressed: () {
                                  if (nameController.text.isNotEmpty) {
                                    exercises.add(RoutineExercise(
                                      name: nameController.text,
                                      sets: int.tryParse(setsController.text) ?? 3,
                                      reps: int.tryParse(repsController.text) ?? 10,
                                      restSeconds: int.tryParse(restController.text) ?? 60,
                                    ));
                                    setModalState(() {});
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Agregar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                ...exercises.asMap().entries.map((e) => ListTile(
                  leading: CircleAvatar(radius: 12, child: Text('${e.key + 1}')),
                  title: Text(e.value.name),
                  subtitle: Text('${e.value.sets}x${e.value.reps}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      exercises.removeAt(e.key);
                      setModalState(() {});
                    },
                  ),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: exercises.isNotEmpty && nameController.text.isNotEmpty && selectedDays.isNotEmpty
                        ? () async {
                            await context.read<RoutineViewModel>().createRoutine(
                              name: nameController.text,
                              description: descController.text.isNotEmpty ? descController.text : null,
                              exercises: exercises,
                              weekDays: selectedDays.toList()..sort(),
                            );
                            if (mounted) Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Crear Rutina'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(int day, String label, Set<int> selectedDays, StateSetter setModalState) {
    final isSelected = selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          selectedDays.add(day);
        } else {
          selectedDays.remove(day);
        }
        setModalState(() {});
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  void _showDeleteConfirmation(BuildContext context, RoutineViewModel viewModel, String routineId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Rutina'),
        content: const Text('¿Estás seguro de que quieres eliminar esta rutina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.deleteRoutine(routineId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rutina eliminada')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showEditRoutineDialog(RoutineModel routine) {
    final nameController = TextEditingController(text: routine.name);
    final descController = TextEditingController(text: routine.description ?? '');
    final selectedDays = <int>{...routine.weekDays};
    final exercises = <RoutineExercise>[...routine.exercises];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Editar Rutina', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre de la rutina'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                ),
                const SizedBox(height: 16),
                const Text('Selecciona los días de la semana:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDayChip(1, 'Lun', selectedDays, setModalState),
                    _buildDayChip(2, 'Mar', selectedDays, setModalState),
                    _buildDayChip(3, 'Mié', selectedDays, setModalState),
                    _buildDayChip(4, 'Jue', selectedDays, setModalState),
                    _buildDayChip(5, 'Vie', selectedDays, setModalState),
                    _buildDayChip(6, 'Sáb', selectedDays, setModalState),
                    _buildDayChip(7, 'Dom', selectedDays, setModalState),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ejercicios (${exercises.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        final exNameController = TextEditingController();
                        final setsController = TextEditingController(text: '3');
                        final repsController = TextEditingController(text: '10');
                        final restController = TextEditingController(text: '60');
                        
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Agregar Ejercicio'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: exNameController, decoration: const InputDecoration(labelText: 'Nombre')),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: TextField(controller: setsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Series'))),
                                    const SizedBox(width: 8),
                                    Expanded(child: TextField(controller: repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps'))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(controller: restController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Descanso (seg)')),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                              ElevatedButton(
                                onPressed: () {
                                  if (exNameController.text.isNotEmpty) {
                                    exercises.add(RoutineExercise(
                                      name: exNameController.text,
                                      sets: int.tryParse(setsController.text) ?? 3,
                                      reps: int.tryParse(repsController.text) ?? 10,
                                      restSeconds: int.tryParse(restController.text) ?? 60,
                                    ));
                                    setModalState(() {});
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Agregar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                ...exercises.asMap().entries.map((e) => ListTile(
                  leading: CircleAvatar(radius: 12, child: Text('${e.key + 1}')),
                  title: Text(e.value.name),
                  subtitle: Text('${e.value.sets}x${e.value.reps}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      exercises.removeAt(e.key);
                      setModalState(() {});
                    },
                  ),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: exercises.isNotEmpty && nameController.text.isNotEmpty && selectedDays.isNotEmpty
                        ? () async {
                            final updatedRoutine = routine.copyWith(
                              name: nameController.text,
                              description: descController.text.isNotEmpty ? descController.text : null,
                              exercises: exercises,
                              weekDays: selectedDays.toList()..sort(),
                            );
                            await context.read<RoutineViewModel>().updateRoutine(updatedRoutine);
                            if (mounted) Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Guardar Cambios'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
