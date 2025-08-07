//
//  BeMeApp.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//

import SwiftUI
import AVFoundation
import Photos

@main
struct BeMeApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
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
}
