import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _goalController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUserId != null) {
        final profileViewModel = context.read<ProfileViewModel>();
        profileViewModel.loadUser(authViewModel.currentUserId!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _loadUserData(ProfileViewModel profileViewModel) {
    if (profileViewModel.user != null) {
      _nameController.text = profileViewModel.user!.name;
      _weightController.text = profileViewModel.user!.weight.toString();
      _heightController.text = profileViewModel.user!.height.toString();
      _goalController.text = profileViewModel.user!.goal;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileViewModel = context.read<ProfileViewModel>();
      
      if (_selectedImage != null) {
        await profileViewModel.updateProfilePhoto(_selectedImage!);
      }

      final success = await profileViewModel.updateProfile(
        name: _nameController.text.trim(),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        goal: _goalController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Perfil actualizado exitosamente!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileViewModel.errorMessage ?? 'Error al actualizar'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    final profileViewModel = context.read<ProfileViewModel>();
    _loadUserData(profileViewModel);
    setState(() {
      _isEditing = false;
      _selectedImage = null;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthViewModel>().logout();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _cancelEdit,
              child: const Text('Cancelar'),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profileViewModel, child) {
          if (profileViewModel.state == ProfileLoadingState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_isEditing) {
            _loadUserData(profileViewModel);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(profileViewModel),
                  const SizedBox(height: 24),
                  if (_isEditing) _buildEditForm(profileViewModel) else _buildProfileInfo(profileViewModel),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: profileViewModel.isSaving ? null : _saveProfile,
                      child: profileViewModel.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Guardar Cambios'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Cerrar Sesión'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel profileViewModel) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: profileViewModel.profilePhotoUrl != null
                  ? NetworkImage(profileViewModel.profilePhotoUrl!)
                  : null,
              child: profileViewModel.profilePhotoUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppTheme.primaryColor,
                    )
                  : null,
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profileViewModel.user?.name ?? 'Usuario',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          profileViewModel.user?.email ?? '',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(ProfileViewModel profileViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu peso';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Altura (cm)',
                prefixIcon: Icon(Icons.height),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu altura';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _goalController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Objetivo Fitness',
                prefixIcon: Icon(Icons.flag_outlined),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu objetivo fitness';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ProfileViewModel profileViewModel) {
    final user = profileViewModel.user;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.monitor_weight_outlined,
              label: 'Peso',
              value: '${user?.weight.toStringAsFixed(1) ?? '0'} kg',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.height,
              label: 'Altura',
              value: '${user?.height.toStringAsFixed(1) ?? '0'} cm',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.flag_outlined,
              label: 'Objetivo',
              value: user?.goal ?? 'No establecido',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
