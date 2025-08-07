//
//  BuildConfig.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//

import Foundation
import UIKit

// Configuración de build para la app
struct BuildConfig {
    
    // Configuración de la app
    static let appName = "BeMe"
    static let appVersion = "1.0"
    static let appBuild = "1"
    static let bundleIdentifier = "com.beme.app"
    
    // Configuración de orientación
    static let supportedOrientations = UIInterfaceOrientationMask.portrait
    
    // Configuración de permisos (se manejan automáticamente por iOS)
    static let requiresCameraPermission = true
    static let requiresPhotoLibraryPermission = true
    
    // Configuración de características
    static let supportsProximitySensor = true
    static let supportsCameraCapture = true
    static let supportsPhotoSaving = true
    
    // Configuración de debugging
    static let enableDetailedLogging = true
    static let enableErrorReporting = true
    
    // Configuración de UI
    static let enableDarkMode = true
    static let enableAnimations = true
    static let enableHapticFeedback = true
} 