# Fitness By TST

Aplicación móvil de seguimiento fitness desarrollada por TST Solutions.

## Descripción

Aplicación Android/iOS para seguimiento de tu rutina de ejercicios y progreso fitness. Permite registrar entrenamientos, monitorear tu peso, calcular tu IMC y ver tu historial de progreso en tiempo real.

## Características

### Módulos
- **Autenticación**: Registro e inicio de sesión con email y contraseña
- **Gestión de Entrenamientos**: Agregar entrenamientos con ejercicios personalizados (series, repeticiones, peso)
- **Seguimiento de Progreso**: Registrar peso y fotos de progreso
- **Perfil de Usuario**: Editar información personal, objetivos fitness y foto de perfil
- **Dashboard**: Ver estadísticas, rutinas del día y entrenamientos recientes
- **Índice de Masa Corporal (IMC)**: Cálculo automático con categoría peso ideal
- **Peso Ideal**: Cálculo del rango de peso ideal según altura
- **Estadísticas Gráficas**: Gráfico de evolución de peso con fl_chart
- **Foto de Perfil**: Subir y actualizar foto de perfil del usuario
- **Rutinas Personalizadas**: Crear rutinas con ejercicios, días de la semana e imagen
- **Rutinas del Día**: Ver y completar las rutinas programadas para hoy con check
- **Temporizador**: Temporizador con alarma sonora para descansos
- **Calorías**: Calculadora de calorías TMB y meta diaria con explicación
- **Plan Nutricional**: Distribución de macros y ejemplos de comidas
- **Modo Oscuro**: Soporte para tema claro y oscuro
- **Medidas Corporales**: Registro de cintura, pecho, brazos, piernas
- **Logros y Badges**: Sistema de logros por entrenamientos y rachas
- **Notificaciones**: Recordatorio diario de entrenamiento
- **Exportar Datos**: Exportar historial de peso y entrenamientos
- **Acerca de TST**: Información de la empresa desarrolladora

### Funcionalidades
- **CRUD Completo**: Crear, leer, actualizar y eliminar entrenamientos y progreso
- **Sincronización en Tiempo Real**: Los datos se guardan directamente en Firestore
- **Fotos de Progreso**: Subir fotos al Storage de Firebase
- **Foto de Perfil**: Subir y actualizar foto de perfil de usuario
- **Completar Rutinas**: Marcar rutinas del día como completadas (+1 entrenamiento)
- **Validaciones**: Validaciones en cliente y servidor
- **Diseño Moderno**: Material Design 3 con interfaz intuitiva
- **Tema Claro/Oscuro**: Toggle para cambiar entre modos
- **Popup Diario**: Pedir peso al usuario cada día
- **Celebración**: Popup de felicidades al completar rutinas
- **Compartir Datos**: Exportar datos como archivo de texto

## Tecnologías

- **Framework**: Flutter
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore (base de datos en la nube)
  - Firebase Storage (fotos de progreso)
- **Arquitectura**: MVVM con Provider
- **Navegación**: GoRouter
- **Gráficos**: fl_chart
- **UI**: Material Design 3

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── model/                       # Modelos de datos
│   ├── user_model.dart         # Modelo usuario (con cálculo IMC)
│   ├── workout_model.dart      # Modelo entrenamiento
│   └── progress_model.dart     # Modelo progreso
├── repository/                  # Repositorios Firebase
│   ├── auth_repository.dart     # Autenticación
│   ├── user_repository.dart    # Usuarios en Firestore
│   ├── workout_repository.dart  # Entrenamientos en Firestore
│   ├── progress_repository.dart # Progreso en Firestore
│   └── storage_repository.dart  # Fotos en Firebase Storage
├── router/                      # Configuración de rutas
│   └── app_router.dart
└── ui/
    ├── theme/                   # Tema de la app
    │   └── app_theme.dart
    ├── viewmodels/              # ViewModels (estado de la app)
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

## Estructura de Base de Datos (Firestore)

### Colección: users
```json
{
  "name": "string",
  "email": "string",
  "weight": number,
  "height": number,
  "goal": "string",
  "createdAt": timestamp,
  "photoUrl": "string (opcional)"
}
```

### Colección: workouts
```json
{
  "userId": "string",
  "date": timestamp,
  "type": "string",
  "exercises": [
    {
      "name": "string",
      "sets": number,
      "reps": number,
      "weight": number
    }
  ],
  "createdAt": timestamp
}
```

### Colección: progress
```json
{
  "userId": "string",
  "weight": number,
  "photoUrl": "string (opcional)",
  "date": timestamp
}
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
5. **Estadísticas**: Ve tu gráfico de evolución de peso
6. **IMC**: Consulta tu índice de masa corporal en el perfil

## Seguridad

- Cada usuario solo puede acceder a sus propios datos
- Validaciones en cliente y servidor
- Autenticación requerida para todas las operaciones
- Reglas de Firestore configuradas para seguridad

## Screenshots

La app incluye las siguientes pantallas:
- Splash Screen
- Login / Registro
- Home (Dashboard con estadísticas)
- Agregar Entrenamiento
- Progreso (Registro y Estadísticas)
- Perfil (con IMC, peso ideal y foto de perfil)

---

**Desarrollado por TST Solutions**

TST Solutions - "Te Solucionamos Todo" es un aliado tecnológico integral que ofrece soluciones completas desde telecomunicaciones hasta desarrollo de software, marketing digital y obra civil.

Con más de 12 años de experiencia, hemos transformado cientos de empresas ayudándolas a dar el gran salto hacia la Transformación Digital.

### Contáctanos:
- 🌐 Web: https://tst-solutions.netlify.app/
- 📘 Facebook: https://www.facebook.com/tstsolutionsecuador/
- 🐦 X: https://x.com/SolutionsT95698
- 📱 WhatsApp: +593 99 796 2747

© 2026 Fitness By TST - Todos los derechos reservados.
