//
//  PrivacyConfig.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//

import Foundation
import UIKit

// Configuración de privacidad para la app
struct PrivacyConfig {
    
    // Descripciones de uso de privacidad que se mostrarán al usuario
    static let cameraUsageDescription = "BeMe necesita acceso a la cámara trasera para capturar fotos espontáneas cuando cubras el sensor de proximidad."
    static let photoLibraryUsageDescription = "BeMe necesita acceso a tu galería para guardar las fotos espontáneas capturadas."
    static let photoLibraryAddUsageDescription = "BeMe guarda automáticamente las fotos espontáneas en tu galería para preservar los momentos reales."
    
    // Configuración de la app
    static let appName = "BeMe"
    static let appVersion = "1.0"
    static let appBuild = "1"
    
    // Configuración de orientación
    static let supportedOrientations = UIInterfaceOrientationMask.portrait
    
    // Configuración de permisos
    static func getPrivacyDescriptions() -> [String: String] {
        return [
            "NSCameraUsageDescription": cameraUsageDescription,
            "NSPhotoLibraryUsageDescription": photoLibraryUsageDescription,
            "NSPhotoLibraryAddUsageDescription": photoLibraryAddUsageDescription
        ]
    }
} 