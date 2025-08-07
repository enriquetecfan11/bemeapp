# BeMe App

## Descripción General
BeMe es una aplicación iOS desarrollada en SwiftUI que permite capturar fotos espontáneas utilizando la cámara trasera del dispositivo. La app utiliza el sensor de proximidad para detectar cuando el usuario acerca el teléfono a su pecho (cubriendo el sensor), momento en el cual se captura una foto automáticamente sin vista previa ni filtros, capturando el momento real.

La app fuerza la orientación vertical (portrait) y solicita permisos para cámara y galería de fotos automáticamente cuando es necesario.

## Requisitos
- iOS 14 o superior
- Dispositivo con cámara trasera y sensor de proximidad (la mayoría de iPhones)

## Configuraciones Principales
- **Orientación**: Solo portrait.
- **Permisos**:
  - Cámara: Para capturar fotos.
  - Galería de fotos: Para guardar las fotos capturadas.
- **Características**:
  - Captura automática al cubrir el sensor de proximidad.
  - Sin flash.
  - Vista previa post-captura con opción de guardar o descartar.

## Pantallas y Vistas Principales

### 1. Pantalla Principal (ContentView)
Esta es la vista inicial de la app:
- **Funcionalidad**: Muestra una vista previa de la cámara trasera.
- **Elementos**:
  - Si los permisos de cámara no están granted, muestra un mensaje solicitando habilitar el permiso en Configuraciones > Privacidad > Cámara.
  - Instrucciones: "Acerca el teléfono a tu pecho" para capturar una foto espontánea.
  - Cuando se detecta proximidad (sensor cubierto), la pantalla se oscurece y se captura la foto automáticamente después de un breve delay.
  - Maneja el sensor de proximidad para trigger la captura.
- **Transiciones**: Al capturar, presenta la Pantalla de Vista Previa de Foto en modo full screen.

### 2. Pantalla de Vista Previa de Foto (PhotoPreviewView)
Presentada después de capturar una foto:
- **Funcionalidad**: Muestra la foto capturada y permite al usuario decidir si guardarla en la galería o descartarla.
- **Elementos**:
  - Imagen capturada en el centro, con aspect ratio preservado.
  - Texto: "Foto Espontánea Capturada" y "¿Quieres guardar esta foto en tu galería?".
  - Botones:
    - "Descartar" (rojo, con ícono de basura): Descarta la foto y regresa a la pantalla principal.
    - "Guardar" (verde, con ícono de guardar): Solicita confirmación y guarda la foto en la galería usando PHPhotoLibrary.
- **Notas**: Muestra un progress view mientras se guarda. iOS maneja permisos automáticamente si no están granted.

## Componentes Clave
- **CameraManager**: Clase que maneja la sesión de AVCaptureSession, permisos de cámara, captura de fotos y guardado en galería.
- **CameraPreview**: Vista representable de UIKit para mostrar la preview de la cámara.
- **BuildConfig**: Estructura con configuraciones estáticas como nombre de app, versión, orientaciones soportadas, etc.
- **Info.plist**: Contiene descripciones de permisos para cámara y galería.

## Flujo de la App
1. La app inicia en ContentView.
2. Solicita permisos si es necesario.
3. Muestra preview de cámara e instrucciones.
4. Al cubrir sensor: Captura foto.
5. Presenta PhotoPreviewView.
6. Usuario elige guardar (se guarda en galería) o descartar (regresa a principal).

## Instalación y Ejecución
- Abre el proyecto en Xcode.
- Compila y ejecuta en un simulador o dispositivo iOS.
- Asegúrate de granting permisos cuando se soliciten.

## Notas Adicionales
- La app está diseñada para capturas espontáneas, sin edición ni filtros.
- Logs detallados están habilitados para debugging.
- Para más detalles, revisa los archivos fuente en la carpeta BeMe/.