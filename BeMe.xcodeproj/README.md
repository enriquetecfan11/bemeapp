# BeMe — Roadmap de Mejoras

Este archivo contiene una lista de tareas priorizadas para elevar la calidad, la robustez y la experiencia de usuario en BeMe. Marca cada casilla al completar cada mejora.

---

## 🚦 Organización y Modularidad

- [ ] Extraer todas las sub-vistas internas (`ErrorView`, `InstructionsView`, `PostCaptureOverlay`, etc.) a archivos propios en la carpeta `Views/`.
- [ ] Crear carpetas por dominio:  
  - `Views/`  
  - `Managers/`  
  - `Services/`  
  - `Extensions/`
- [ ] Centralizar la lógica de feedback háptico en un `HapticsManager` reutilizable.
- [ ] Centralizar la lógica para compartir imágenes en un único servicio o helper.

---

## 🎨 UI, Accesibilidad y Localización

- [ ] Añadir soporte de **localización** usando archivos `.strings` y `NSLocalizedString` en todos los textos.
- [ ] Implementar descripciones de **accesibilidad** (`.accessibilityLabel`, `.accessibilityHint`) en botones, imágenes y banners.
- [ ] Agregar soporte para **Dynamic Type** y tamaños de texto grandes en toda la app.
- [ ] Mejorar la responsividad usando layouts adaptativos modernos (`ViewThatFits`, stacks adaptativos).

---

## 🧠 Gestión de Estado y Arquitectura

- [ ] Definir un `enum` para el estado principal de la UI (por ejemplo: `.instructions`, `.proximity`, `.capturing`, `.success`, `.error`).
- [ ] Crear un `ContentViewModel` para desacoplar la lógica de negocio de la vista principal.
- [ ] Migrar timers (`Timer.scheduledTimer`) y animaciones a Combine o Swift Concurrency para evitar fugas y mejorar la cancelación.
- [ ] Unificar y documentar la gestión de sesiones de cámara y sensores.

---

## 🔐 Permisos, Errores y Privacidad

- [ ] Mejorar los mensajes de error para que sean claros y amigables.
- [ ] Implementar respuesta en tiempo real a cambios de permisos (cámara, fotos).
- [ ] Revisar y actualizar las descripciones en `Info.plist` para todos los permisos requeridos.
- [ ] Revisar que la app no exponga información sensible ni imágenes sin consentimiento del usuario.

---

## 📦 Performance y Recursos

- [ ] Usar miniaturas o referencias ligeras en banners en vez de pasar imágenes completas si la foto es pesada.
- [ ] Garantizar que las sesiones de cámara y PhotoLibrary se detienen/liberan cuando no son necesarias.
- [ ] Optimizar y documentar el uso de memoria en previews y en `PhotoLibraryManager`.

---

## 🛠️ Testing y Previews

- [ ] Añadir tests unitarios para los managers (`CameraManager`, `PhotoLibraryManager`, etc.) usando el framework Swift Testing.
- [ ] Añadir tests de integración end-to-end (flujo de captura, guardado y compartido).
- [ ] Incluir `#Preview` en todas las vistas, simulando estados de error, éxito, permisos denegados, etc.
- [ ] Documentar cómo correr los tests y agregar snapshots de ejemplo.

---

## 🧩 Detalles Finos y Limpieza

- [ ] Eliminar o envolver (`#if DEBUG`) los prints de debugging para producción.
- [ ] Documentar extensiones y helpers propios con comentarios claros.
- [ ] Revisar y eliminar cualquier código duplicado o sin uso.

---

## 🚀 Ideas Futuras

- [ ] Permitir configuración avanzada de la cámara (presets adicionales).
- [ ] Mejorar el onboarding con tips interactivos o posibilidad de omitirlo.
- [ ] Añadir soporte para widgets o atajos de Siri adicionales.
- [ ] Implementar un sistema de feedback o reporte para usuarios.

---

> **¿Cómo contribuir?**  
Haz fork, crea tu rama, y envía un Pull Request por cada mejora.  
Discute las decisiones de arquitectura en los issues del repositorio para alinear el roadmap.

---
