# BeMe — Funcionalidades Nuevas (Roadmap Realista)

Este documento presenta funcionalidades realistas y alcanzables para BeMe, priorizando mejoras incrementales que aporten valor inmediato al usuario sin comprometer la simplicidad de la app.

---

## ✅ Funcionalidades Completadas

### 1. Sistema de Onboarding
**Estado**: ✅ Implementado
- Pantallas de introducción para nuevos usuarios
- Explicación del gesto de proximidad
- Configuración automática de permisos

---

## 🚀 Funcionalidades Pendientes (Por Prioridad)

## Alta Prioridad

### 2. Flash Automático Inteligente
**Objetivo**: Mejorar fotos en condiciones de poca luz sin intervención manual.

**Descripción**: 
- Detectar automáticamente condiciones de poca luz usando `AVCaptureDevice.iso` y `exposureDuration`
- Activar flash solo cuando sea necesario
- Configuración para forzar flash ON/OFF/AUTO

**Implementación**:
```swift
// En CameraManager.swift
private func shouldUseFlash() -> Bool {
    guard let device = session.inputs.first?.device else { return false }
    return device.iso > 200 // Umbral ajustable
}

// Aplicar en takePhoto()
settings.flashMode = shouldUseFlash() ? .on : .off
```

**Configuración**: Toggle en SettingsView: "Flash Automático"

**Esfuerzo**: Bajo (2-3 horas)
**Riesgo**: Bajo

---

### 3. Contador de Fotos y Estadísticas Básicas
**Objetivo**: Dar contexto al usuario sobre su actividad fotográfica.

**Descripción**:
- Mostrar contador de fotos tomadas en la sesión actual
- Estadísticas simples: fotos del día, semana, total
- Badge discreto en la interfaz principal

**Implementación**:
```swift
// Nuevo @AppStorage en CameraManager
@AppStorage("totalPhotosCount") private var totalPhotosCount: Int = 0
@AppStorage("photosToday") private var photosToday: Int = 0
@AppStorage("lastPhotoDate") private var lastPhotoDate: String = ""

// Incrementar contadores en savePhotoToGallery()
```

**UI**: Badge sutil en esquina superior con animación al incrementar

**Esfuerzo**: Bajo (3-4 horas)
**Riesgo**: Muy bajo

---

### 4. Modo Silencioso Mejorado
**Objetivo**: Captura completamente discreta en situaciones que lo requieran.

**Descripción**:
- Desactivar todos los sonidos del sistema durante captura
- Reducir brillo de pantalla temporalmente 
- Ocultar animaciones de captura
- Feedback háptico mínimo

**Implementación**:
```swift
// Nuevo toggle en SettingsView
@AppStorage("silentMode") private var silentMode: Bool = false

// En handleProximityChange() - aplicar configuraciones silenciosas
if silentMode {
    UIScreen.main.brightness = max(UIScreen.main.brightness * 0.3, 0.1)
    // Desactivar animaciones de captura
    // Usar solo feedback háptico muy suave
}
```

**Esfuerzo**: Medio (4-5 horas)
**Riesgo**: Bajo

---

### 5. Galería Rápida (Vista Previa de Últimas Fotos)
**Objetivo**: Acceso rápido a las últimas fotos sin salir de la app.

**Descripción**:
- Botón flotante que muestra las últimas 3-5 fotos del álbum BeMe
- Swipe gestures para navegar
- Opciones básicas: compartir, eliminar
- Transición suave desde la interfaz principal

**Implementación**:
```swift
// Nuevo view: QuickGalleryView
struct QuickGalleryView: View {
    @State private var recentPhotos: [UIImage] = []
    
    // Usar PhotoLibraryManager para cargar últimas fotos
    // TabView con PageTabViewStyle para swipe
}

// Botón en ContentView con sheet presentation
```

**Esfuerzo**: Medio (6-8 horas)
**Riesgo**: Medio (permisos de Photos)

---

### 6. Filtros Básicos Post-Captura
**Objetivo**: Mejoras simples de imagen sin comprometer la filosofía "sin filtros".

**Descripción**:
- 3 filtros sutiles: "Calidez", "Contraste", "Claridad"
- Aplicación opcional en la vista post-captura
- Preservar siempre la foto original

**Implementación**:
```swift
// Usar Core Image filters básicos
extension UIImage {
    func applySubtleWarming() -> UIImage { /* CIColorControls */ }
    func applyContrast() -> UIImage { /* CIExposureAdjust */ }
    func applyClarify() -> UIImage { /* CIUnsharpMask suave */ }
}

// Nuevos botones en PostCaptureOverlay
```

**Esfuerzo**: Medio (5-6 horas)
**Riesgo**: Bajo

---

## Media Prioridad

### 7. Exportación en Diferentes Formatos
**Objetivo**: Flexibilidad en el almacenamiento según necesidades del usuario.

**Descripción**:
- Opciones: HEIC (compacto), JPEG Alta, JPEG Media
- Configuración global en Settings
- Información de tamaño estimado

**Implementación**:
```swift
// Enum para formatos
enum ExportFormat: String, CaseIterable {
    case heic = "HEIC (Compacto)"
    case jpegHigh = "JPEG Alta Calidad"
    case jpegMedium = "JPEG Calidad Media"
}

// Picker en SettingsView
// Modificar addWatermark() para manejar formatos
```

**Esfuerzo**: Medio (4-5 horas)
**Riesgo**: Bajo

---

### 8. Backup Automático a iCloud
**Objetivo**: Sincronización automática y respaldo de fotos BeMe.

**Descripción**:
- Configuración automática si iCloud Photos está habilitado
- Toggle para activar/desactivar backup
- Indicador de estado de sincronización

**Implementación**:
```swift
// Verificar estado de iCloud Photos
import CloudKit

// Función para verificar disponibilidad de iCloud
private func checkiCloudAvailability() -> Bool {
    return FileManager.default.ubiquityIdentityToken != nil
}

// Auto-tag en metadatos para identificar fotos BeMe
```

**Esfuerzo**: Alto (8-10 horas)
**Riesgo**: Medio (APIs de iCloud)

---

### 9. Widget de iOS (Compacto)
**Objetivo**: Acceso rápido desde pantalla de inicio y estadísticas.

**Descripción**:
- Widget pequeño con contador de fotos del día
- Tap para abrir app directamente
- Actualización automática cada hora

**Implementación**:
```swift
// Nuevo target: BeMeWidget
// WidgetKit configuration
struct BeMeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BeMe", provider: Provider()) { entry in
            BeMeWidgetView(entry: entry)
        }
        .configurationDisplayName("BeMe Fotos")
        .description("Contador de fotos espontáneas de hoy")
        .supportedFamilies([.systemSmall])
    }
}
```

**Esfuerzo**: Medio (6-7 horas)
**Riesgo**: Bajo

---

### 10. Compartir Directo a Redes Sociales
**Objetivo**: Integración nativa con plataformas principales.

**Descripción**:
- Botones dedicados para Instagram Stories, WhatsApp, Twitter
- Respeto de políticas de privacidad
- Opciones de redimensionado automático

**Implementación**:
```swift
// Usar UIActivityViewController con tipos específicos
// Extensión en shareImage() para plataformas específicas
private func shareToInstagramStories(_ image: UIImage) {
    // URL scheme de Instagram
    // Configuración específica para Stories
}
```

**Esfuerzo**: Medio (5-6 horas)
**Riesgo**: Medio (dependencias externas)

---

### 11. Modo Retrato Básico
**Objetivo**: Aprovechar capacidades de dispositivos con múltiples cámaras.

**Descripción**:
- Detección automática de sujeto humano
- Aplicación sutil de desenfoque de fondo
- Solo en dispositivos compatibles

**Implementación**:
```swift
// Verificar disponibilidad de modo retrato
if AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) != nil {
    // Configurar AVCapturePhotoOutput con portraitEffectsMatteDeliveryEnabled
}
```

**Esfuerzo**: Alto (8-10 horas)
**Riesgo**: Alto (compatibilidad dispositivos)

---

## Estimación de Desarrollo

| Feature | Esfuerzo | Riesgo | Impacto Usuario |
|---------|----------|--------|-----------------|
| Flash Automático | 3h | Bajo | Alto |
| Contador Fotos | 4h | Muy Bajo | Medio |
| Modo Silencioso | 5h | Bajo | Alto |
| Galería Rápida | 8h | Medio | Alto |
| Filtros Básicos | 6h | Bajo | Medio |
| Formatos Export | 5h | Bajo | Medio |
| Backup iCloud | 10h | Medio | Alto |
| Widget iOS | 7h | Bajo | Medio |
| Redes Sociales | 6h | Medio | Medio |
| Modo Retrato | 10h | Alto | Alto |

## Criterios de Implementación

### ✅ Implementar Si:
- Mejora la experiencia sin complicar la UI
- Se puede implementar en < 8 horas
- No requiere permisos adicionales complejos
- Es coherente con la filosofía de simplicidad

### ❌ Evitar Si:
- Agrega complejidad significativa a la UI
- Requiere múltiples pantallas nuevas
- Compromete el rendimiento o la estabilidad
- Necesita integraciones externas complejas

## Notas Técnicas

### Compatibilidad
- iOS 18.5+ (versión actual del proyecto)
- Dispositivos con sensor de proximidad
- Cámara trasera obligatoria

### Rendimiento
- Mantener tiempo de captura < 2 segundos
- Uso de memoria < 50MB adicionales
- Battery impact mínimo

### Privacidad
- Sin recolección de datos del usuario
- Permisos solicitados solo cuando sean necesarios
- Almacenamiento local prioritario sobre cloud

---

## Metodología de Desarrollo

1. **Prototipo Rápido**: Implementar versión básica en 2-3 horas
2. **Testing en Dispositivo**: Pruebas con casos reales de uso
3. **Refinamiento**: Pulir interacciones y rendimiento
4. **Documentación**: Actualizar README y comentarios en código

## Conclusión

Este roadmap prioriza mejoras **incrementales y realizables** que mantienen la esencia de BeMe: simplicidad, espontaneidad y facilidad de uso. Cada feature está diseñada para implementarse de forma modular sin afectar la funcionalidad existente.

**Siguiente paso recomendado**: Implementar Flash Automático (alta prioridad, bajo riesgo, alto impacto).
