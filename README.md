# Fitness By TST

Aplicación móvil de seguimiento fitness desarrollada por TST Solutions.

## Descripción

Aplicación Android/IOS para seguimiento de tu rutina de ejercicios y progreso fitness. Permite registrar entrenamientos, monitorear tu peso y ver tu historial de progreso.

## Características

- **Autenticación**: Registro e inicio de sesión con email y contraseña
- **Gestión de Entrenamientos**: Agregar entrenamientos con ejercicios personalizados
- **Seguimiento de Progreso**: Registrar peso y fotos de progreso
- **Perfil de Usuario**: Editar información personal y objetivos fitness
- **Dashboard**: Ver estadísticas y entrenamientos recientes
- **Diseño Moderno**: Material Design 3 con interfaz intuitiva

## Tecnologías

- **Framework**: Flutter
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **Arquitectura**: MVVM con Provider
- **Navegación**: GoRouter
- **UI**: Material Design 3

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── model/                       # Modelos de datos
│   ├── user_model.dart
│   ├── workout_model.dart
│   └── progress_model.dart
├── repository/                  # Repositorios Firebase
│   ├── auth_repository.dart
│   ├── user_repository.dart
│   ├── workout_repository.dart
│   ├── progress_repository.dart
│   └── storage_repository.dart
├── router/                      # Configuración de rutas
│   └── app_router.dart
└── ui/
    ├── theme/                   # Tema de la app
    │   └── app_theme.dart
    ├── viewmodels/              # ViewModels
    │   ├── auth_viewmodel.dart
    │   ├── home_viewmodel.dart
    │   ├── workout_viewmodel.dart
    │   ├── progress_viewmodel.dart
    │   └── profile_viewmodel.dart
    └── screens/                 # Pantallas
        ├── splash/
        ├── auth/
        ├── home/
        ├── workout/
        ├── progress/
        └── profile/
```

## Requisitos

- Flutter SDK 3.x
- Dart 3.x
- Cuenta de Firebase configurada

## Instalación

1. Clona el repositorio
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Configura Firebase:
   - Descarga `google-services.json` desde Firebase Console
   - Colócalo en `android/app/google-services.json`
4. Ejecuta la app:
   ```bash
   flutter run
   ```

## Configuración Firebase

### Authentication
- Habilita "Email/Password" en Firebase Authentication

### Firestore
- Crea las colecciones: `users`, `workouts`, `progress`
- Configura las reglas de seguridad en `firestore.rules`

### Storage
- Habilita Firebase Storage
- Configura reglas para permitir lectura/escritura autenticada

## Uso

1. **Registro**: Crea una cuenta con email y contraseña
2. **Perfil**: Completa tu información personal (peso, altura, objetivo)
3. **Entrenamientos**: Agrega tus entrenamientos con ejercicios
4. **Progreso**: Registra tu peso regularmente con fotos opcional

## Seguridad

- Cada usuario solo puede acceder a sus propios datos
- Validaciones en cliente y servidor
- Autenticación requerida para todas las operaciones

## Screenshots

La app incluye las siguientes pantallas:
- Splash Screen
- Login / Registro
- Home (Dashboard)
- Agregar Entrenamiento
- Progreso
- Perfil

---

**Desarrollado por TST Solutions**

© 2026 Fitness By TST - Todos los derechos reservados.
