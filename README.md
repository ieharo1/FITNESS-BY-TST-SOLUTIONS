# 🟢 TST SOLUTIONS - Fitness By TST

**Fitness By TST** es una aplicación móvil de seguimiento fitness desarrollada por **TST Solutions** ("Te Solucionamos Todo").

---

## 📱 ¿Qué es Fitness By TST?

**Fitness By TST** es una aplicación móvil de seguimiento fitness que te permite gestionar tu rutina de ejercicios, monitorear tu peso, calcular tu IMC y ver tu historial de progreso en tiempo real.

> *"Tecnología que funciona. Soluciones que escalan."*

---

## ✨ Características Principales

### 🏋️ Gestión de Entrenamientos
- Agregar entrenamientos con ejercicios personalizados
- Registrar series, repeticiones y peso
- Rutinas personalizadas por días de la semana

### 📊 Seguimiento de Progreso
- Registrar peso y fotos de progreso
- Gráfico de evolución de peso
- Medidas corporales (cintura, pecho, brazos, piernas)

### 📈 Estadísticas y Gráficos
- Cálculo automático de IMC con categoría de peso ideal
- Cálculo del rango de peso ideal según altura
- Calculadora de calorías TMB y meta diaria
- Plan nutricional con distribución de macros

### 🏆 Gamificación
- Sistema de logros y badges
- Rachas de entrenamientos
- Celebración al completar rutinas

### ⚙️ Funcionalidades Adicionales
- Temporizador con alarma para descansos
- Recordatorio diario de entrenamiento
- Exportar datos como archivo de texto
- Modo claro/oscuro

---

## 🏗️ Estructura Técnica del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── model/                       # Modelos de datos
│   ├── user_model.dart         # Modelo usuario
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
    └── screens/                 # Pantallas
```

---

## 🛠️ Tecnologías Utilizadas

- **Framework:** Flutter 3.x (Dart 3.x)
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **Estado:** Provider (MVVM)
- **Navegación:** GoRouter
- **Gráficos:** fl_chart
- **UI:** Material Design 3

---

## 🎨 Identidad Visual

### Paleta de Colores
- **Primary:** #1E3A5F (Azul profundo)
- **Secondary:** #00BFA5 (Verde azulado)
- **Accent:** #FF5722 (Naranja)
- **Background:** #F5F7FA (Gris claro)

### Tipografía
- **Títulos:** System Default (Bold)
- **Contenido:** System Default (Regular)

---

## 🏆 Características Técnicas

✅ Diseño 100% responsive  
✅ Interfaz moderna y atractiva  
✅ Gráficos interactivos y animados  
✅ Navegación fluida con transiciones  
✅ Almacenamiento en la nube (Firebase)  
✅ Soporte para Android e iOS  
✅ Código limpio y escalable  

---

## 🌎 Información de Contacto - TST Solutions

📍 **Quito - Ecuador**

📱 **WhatsApp:** +593 99 796 2747  
💬 **Telegram:** @TST_Ecuador  
📧 **Email:** negocios@tstsolutions.com.ec

🌐 **Web:** https://ieharo1.github.io/TST-SOLUTIONS/
📘 **Facebook:** https://www.facebook.com/tstsolutionsecuador/  
🐦 **Twitter/X:** https://x.com/SolutionsT95698

---

## 📋 Requisitos del Sistema

- **Android:** 5.0 (API 21) o superior
- **iOS:** 12.0 o superior
- **Espacio:** ~80 MB

---

## 📄 Licencia

© 2026 Fitness By TST by TST SOLUTIONS - Todos los derechos reservados.

---

## 👨‍💻 Desarrollado por TST SOLUTIONS

*Technology that works. Solutions that scale.*

---

<div align="center">
  <p><strong>TST Solutions</strong> - Te Solucionamos Todo</p>
</div>
