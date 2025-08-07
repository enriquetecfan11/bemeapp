//
//  BeMeApp.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//

import SwiftUI
import AVFoundation
import Photos
import Intents

@main
struct BeMeApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .onContinueUserActivity("com.beme.takephoto") { userActivity in
                    handleSiriShortcut(userActivity)
                }
                .onContinueUserActivity("com.beme.opencamera") { userActivity in
                    handleSiriShortcut(userActivity)
                }
        }
    }
    
    init() {
        // Configurar la app para usar solo orientación vertical
        setupAppConfiguration()
        
        // Configurar permisos de privacidad
        setupPrivacyPermissions()
    }
    
    private func setupAppConfiguration() {
        // Configurar orientación de la app
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }
    
    private func setupPrivacyPermissions() {
        // Los permisos se solicitarán automáticamente cuando se acceda a la cámara
        // y a la galería de fotos por primera vez
        // Las descripciones se mostrarán automáticamente usando las claves del sistema
    }
    
    // MARK: - Siri Shortcuts
    
    private func handleSiriShortcut(_ userActivity: NSUserActivity) {
        print("🎤 Siri shortcut recibido: \(userActivity.activityType)")
        
        switch userActivity.activityType {
        case "com.beme.takephoto":
            NotificationCenter.default.post(
                name: NSNotification.Name("SiriTakePhotoShortcut"),
                object: nil
            )
        case "com.beme.opencamera":
            NotificationCenter.default.post(
                name: NSNotification.Name("SiriOpenCameraShortcut"),
                object: nil
            )
        default:
            break
        }
    }
}
