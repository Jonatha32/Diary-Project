# Diario Emocional

Una aplicación de diario personal para registrar y visualizar tus emociones.

## Configuración de Firebase

Para que la autenticación funcione correctamente, necesitas configurar Firebase en tu proyecto:

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Registra tu aplicación Android/iOS en Firebase
3. Descarga el archivo de configuración `google-services.json` para Android o `GoogleService-Info.plist` para iOS
4. Coloca el archivo en la ubicación correcta:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## Características

- Autenticación de usuarios (registro, inicio de sesión, recuperación de contraseña)
- Registro de emociones diarias
- Visualización de tendencias emocionales
- Interfaz de usuario moderna y atractiva

## Tecnologías utilizadas

- Flutter
- Firebase Authentication
- Provider para gestión de estado
- Gráficos interactivos con fl_chart