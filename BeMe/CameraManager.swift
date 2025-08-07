//
//  CameraManager.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//

import AVFoundation
import UIKit
import Photos
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    @Published var isSessionRunning = false
    @Published var errorMessage: String?
    @Published var isCapturing = false
    @Published var cameraPermissionGranted = false
    @Published var capturedImage: UIImage?
    @Published var showPhotoPreview = false
    @Published var showShareBanner = false
    
    // Settings
    @AppStorage("captureDelay") private var captureDelay: Double = 0.0
    @AppStorage("showShareBanner") private var showShareBannerSetting: Bool = true
    @AppStorage("enableHapticFeedback") private var enableHapticFeedback: Bool = true
    @AppStorage("showWatermark") private var showWatermark: Bool = true

    override init() {
        super.init()
        checkPermissions()
    }

    private func checkPermissions() {
        // Verificar permiso de cámara
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
            configure()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermissionGranted = granted
                    if granted {
                        self?.configure()
                    } else {
                        self?.errorMessage = "Se necesita permiso de cámara para usar esta app"
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
            errorMessage = "Se necesita permiso de cámara. Ve a Configuración > Privacidad > Cámara"
        @unknown default:
            cameraPermissionGranted = false
            errorMessage = "Error desconocido con permisos de cámara"
        }
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No se puede acceder a la cámara trasera")
            errorMessage = "No se puede acceder a la cámara trasera"
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                print("No se puede agregar input de cámara")
                errorMessage = "No se puede configurar la cámara"
                return
            }
        } catch {
            print("Error configurando cámara: \(error)")
            errorMessage = "Error configurando cámara: \(error.localizedDescription)"
            return
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            print("No se puede agregar output de foto")
            errorMessage = "No se puede configurar la captura de fotos"
            return
        }

        session.commitConfiguration()
    }

    func startSession() {
        guard cameraPermissionGranted else {
            errorMessage = "Se necesita permiso de cámara para usar esta app"
            return
        }
        
        guard !session.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = self?.session.isRunning ?? false
            }
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }

    func takePhoto() {
        print("🔄 Intentando tomar foto...")
        
        guard session.isRunning else {
            print("❌ Sesión de cámara no está ejecutándose")
            errorMessage = "Cámara no está lista"
            return
        }
        
        guard !isCapturing else {
            print("❌ Ya se está capturando una foto")
            return
        }

        isCapturing = true
        print("📸 Iniciando captura de foto con retardo de \(captureDelay)s...")
        
        // Aplicar retardo si está configurado
        let delay = captureDelay
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            
            // Realizar la captura
            self.output.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func savePhotoToGallery() {
        guard let image = capturedImage else { return }
        
        // Usar PhotoLibraryManager para guardar en álbum dedicado
        PhotoLibraryManager.shared.saveImageToBeMeAlbum(image) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ Foto espontánea guardada en álbum BeMe exitosamente")
                    self?.errorMessage = nil
                    
                    // Mostrar banner de compartir si está habilitado
                    if self?.showShareBannerSetting == true {
                        self?.showShareBanner = true
                    }
                    
                    self?.capturedImage = nil
                    self?.showPhotoPreview = false
                    
                    // Feedback háptico de éxito
                    if self?.enableHapticFeedback == true {
                        let successFeedback = UINotificationFeedbackGenerator()
                        successFeedback.notificationOccurred(.success)
                    }
                } else {
                    print("❌ Error guardando imagen en álbum BeMe: \(error?.localizedDescription ?? "Error desconocido")")
                    self?.errorMessage = "Error guardando imagen: \(error?.localizedDescription ?? "Error desconocido")"
                    
                    // Feedback háptico de error
                    if self?.enableHapticFeedback == true {
                        let errorFeedback = UINotificationFeedbackGenerator()
                        errorFeedback.notificationOccurred(.error)
                    }
                }
            }
        }
    }
    
    func discardPhoto() {
        capturedImage = nil
        showPhotoPreview = false
    }
    
    private func addWatermark(to image: UIImage) -> UIImage {
        let imageSize = image.size
        let scale = image.scale
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        // Dibujar la imagen original
        image.draw(in: CGRect(origin: .zero, size: imageSize))
        
        // Configurar la marca de agua
        let watermarkText = "BeMe"
        let font = UIFont.systemFont(ofSize: min(imageSize.width, imageSize.height) * 0.04, weight: .medium)
        let textColor = UIColor.white.withAlphaComponent(0.6)
        let shadowColor = UIColor.black.withAlphaComponent(0.8)
        
        // Crear el estilo del texto con sombra
        let textStyle: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .shadow: {
                let shadow = NSShadow()
                shadow.shadowColor = shadowColor
                shadow.shadowOffset = CGSize(width: 1, height: 1)
                shadow.shadowBlurRadius = 2
                return shadow
            }()
        ]
        
        // Calcular el tamaño del texto
        let textSize = watermarkText.size(withAttributes: textStyle)
        
        // Posicionar la marca de agua en la esquina inferior derecha con margen
        let margin: CGFloat = min(imageSize.width, imageSize.height) * 0.03
        let textRect = CGRect(
            x: imageSize.width - textSize.width - margin,
            y: imageSize.height - textSize.height - margin,
            width: textSize.width,
            height: textSize.height
        )
        
        // Dibujar la marca de agua
        watermarkText.draw(in: textRect, withAttributes: textStyle)
        
        // Obtener la imagen final
        let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return watermarkedImage
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📸 Comenzando captura...")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📸 Capturando foto...")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("📸 Procesando foto...")
        
        DispatchQueue.main.async { [weak self] in
            self?.isCapturing = false
        }
        
        if let error = error {
            print("❌ Error capturando foto: \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Error capturando foto: \(error.localizedDescription)"
            }
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("❌ No se pudo procesar la imagen capturada")
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "No se pudo procesar la imagen"
            }
            return
        }

        print("✅ Imagen procesada correctamente...")

        // Aplicar marca de agua solo si está habilitada
        let finalImage = showWatermark ? addWatermark(to: image) : image
        
        if showWatermark {
            print("✅ Marca de agua BeMe aplicada")
        } else {
            print("ℹ️ Foto sin marca de agua (configuración deshabilitada)")
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = finalImage
            self?.showPhotoPreview = true
        }
    }
}
