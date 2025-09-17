# BeMe

Aplicación iOS en SwiftUI para capturar fotos espontáneas con la cámara trasera al cubrir el sensor de proximidad. Sin vista previa ni filtros: enfoca el momento real. Integra atajos de Siri, feedback háptico, un álbum dedicado en Fotos y un panel post‑captura con Guardar/Descartar/Compartir.

## Requisitos
- iOS 18.5 o superior (deployment target del proyecto).
- iPhone con sensor de proximidad y cámara trasera.
- Xcode compatible con iOS 18.5 SDK.

## Características Clave
- Captura por proximidad
  - Activa el sensor (UIDevice.proximityMonitoringEnabled) y dispara al cubrirlo.
  - Animaciones de overlay “capturando” y check de éxito.
  - Feedback háptico configurable.
- Post‑captura
  - Panel full‑screen con miniatura y acciones: Guardar, Descartar, Compartir.
  - Banner de compartir opcional tras guardar.
- Álbum “BeMe”
  - Crea/usa álbum propio en la fototeca y añade las fotos allí.
- Siri Shortcuts
  - Dona actividades “Tomar foto con BeMe” (`com.beme.takephoto`) y “Abrir BeMe” (`com.beme.opencamera`).
  - Botón en Ajustes para añadir comando de voz con la UI de Intents.
- Ajustes
  - Retardo de captura: 0.0 / 0.5 / 1.0 s.
  - Mostrar banner de compartir.
  - Activar/desactivar feedback háptico.
  - Activar/desactivar marca de agua “BeMe”.
- Interfaz
  - Pantalla de lanzamiento animada con latido y transición a la app.
  - Vista principal con preview de cámara, instrucciones y botón de Ajustes.
  - Orientación bloqueada a vertical.

## Arquitectura y Código
- Entrada: `BeMe/BeMeApp.swift`
  - `@main` SwiftUI App. Fuerza orientación vertical con `UIWindowScene.requestGeometryUpdate`.
  - Maneja `NSUserActivity` de Siri y reenvía a la UI vía `NotificationCenter`.
- Vista principal: `BeMe/ContentView.swift`
  - Gestiona permisos, sensor de proximidad, estados de captura, animaciones, panel post‑captura y hoja de compartir.
  - Muestra `CameraPreview` cuando hay permiso; instrucciones y estados si no.
- Cámara: `BeMe/CameraManager.swift`
  - `AVCaptureSession` y `AVCapturePhotoOutput`; permisos, captura con retardo, marca de agua opcional, estados publicados.
  - Guarda a través de `PhotoLibraryManager` y controla el banner de compartir.
- Fototeca: `BeMe/PhotoLibraryManager.swift`
  - Busca/crea álbum “BeMe”. Guarda el asset y lo añade al álbum.
- Siri: `BeMe/SiriShortcutsManager.swift`
  - Dona actividades, maneja shortcuts (notifica por `NotificationCenter`) y presenta `INUIAddVoiceShortcutViewController`.
- UI auxiliar
  - `BeMe/LaunchScreenView.swift`: animación de lanzamiento y transición.
  - `BeMe/CameraPreview.swift`: `UIViewRepresentable` con `AVCaptureVideoPreviewLayer`.
  - `BeMe/ShareBannerView.swift`: banner inferior para compartir.
  - `BeMe/SettingsView.swift`: ajustes con `@AppStorage`.
- Configuración
  - `BeMe/Info.plist`: descripciones de privacidad y actividades de Siri.
  - `BeMe/BuildConfig.swift` y `BeMe/PrivacyConfig.swift`: constantes de build/privacidad.
  - `BeMe/Assets.xcassets`: iconos, acentos y color de Launch Screen.

## Permisos y Privacidad
- Claves en `Info.plist`:
  - `NSCameraUsageDescription`: acceso a cámara para capturar.
  - `NSPhotoLibraryUsageDescription`: acceso a fotos para guardar.
  - `NSPhotoLibraryAddUsageDescription`: añadir al álbum dedicado.
  - `NSSiriUsageDescription`: usar Siri para atajos.
  - `NSUserActivityTypes`: `com.beme.takephoto`, `com.beme.opencamera`.
- Solicitud a demanda
  - Cámara al iniciar la sesión; Fotos al guardar.

## Uso
- Abre la app y concede permisos.
- Acerca el iPhone (cubriendo el sensor de proximidad) para disparar la foto.
- En el panel post‑captura: Guardar (álbum BeMe), Descartar o Compartir (sheet del sistema).
- Ajustes (icono engranaje): retardo, marca de agua, banner de compartir y háptica; añadir Atajo de Siri.

## Ejecución
- Abre `BeMe.xcodeproj` en Xcode y selecciona un dispositivo real (el simulador no tiene sensor de proximidad).
- Compila y ejecuta. La orientación está bloqueada a vertical.

## Estructura del Proyecto
- `BeMe/BeMeApp.swift`: punto de entrada y orientación.
- `BeMe/ContentView.swift`: UI principal y flujo de captura.
- `BeMe/CameraManager.swift`: sesión/captura AVFoundation y marca de agua.
- `BeMe/PhotoLibraryManager.swift`: álbum y guardado en Fotos.
- `BeMe/SiriShortcutsManager.swift`: donación y manejo de atajos.
- `BeMe/SettingsView.swift`: ajustes con `@AppStorage`.
- `BeMe/ShareBannerView.swift`: banner de compartir.
- `BeMe/LaunchScreenView.swift`: animación de lanzamiento.
- `BeMe/CameraPreview.swift`: preview de cámara.
- `BeMe/Info.plist`, `BeMe/Assets.xcassets`: configuración y recursos.

## Limitaciones y Notas
- Requiere dispositivo físico para probar proximidad.
- La cámara usa el lente trasero sin flash; composición mínima.
- Marca de agua “BeMe” opcional; posicionada de forma proporcional.
- No hay backend ni analítica; las fotos permanecen locales.
