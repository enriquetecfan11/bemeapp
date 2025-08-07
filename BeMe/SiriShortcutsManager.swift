//
//  SiriShortcutsManager.swift
//  BeMe
//
//  Created by Assistant on 6/8/25.
//

import Foundation
import Intents
import IntentsUI

class SiriShortcutsManager: ObservableObject {
    static let shared = SiriShortcutsManager()
    
    private init() {
        setupShortcuts()
    }
    
    // MARK: - Configuración de Shortcuts
    
    func setupShortcuts() {
        createTakePhotoActivity()
        createOpenCameraActivity()
    }
    
    private func createTakePhotoActivity() {
        let activity = NSUserActivity(activityType: "com.beme.takephoto")
        activity.title = "Tomar foto con BeMe"
        activity.userInfo = ["action": "takephoto"]
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = "com.beme.takephoto"
        activity.suggestedInvocationPhrase = "Tomar foto con BeMe"
        
        // Hacer la actividad actual para donarla
        activity.becomeCurrent()
        
        print("✅ Take photo activity donated successfully")
    }
    
    private func createOpenCameraActivity() {
        let activity = NSUserActivity(activityType: "com.beme.opencamera")
        activity.title = "Abrir BeMe"
        activity.userInfo = ["action": "opencamera"]
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = "com.beme.opencamera"
        activity.suggestedInvocationPhrase = "Abrir BeMe"
        
        // Hacer la actividad actual para donarla
        activity.becomeCurrent()
        
        print("✅ Open camera activity donated successfully")
    }
    
    // MARK: - Manejo de Shortcuts
    
    func handleShortcut(_ activity: NSUserActivity) -> Bool {
        guard let action = activity.userInfo?["action"] as? String else { return false }
        
        switch action {
        case "takephoto":
            handleTakePhotoShortcut()
            return true
        case "opencamera":
            handleOpenCameraShortcut()
            return true
        default:
            return false
        }
    }
    
    private func handleTakePhotoShortcut() {
        print("🎤 Siri shortcut: Activando captura de foto")
        
        // Notificar a la app principal que debe activar el modo captura
        NotificationCenter.default.post(
            name: NSNotification.Name("SiriTakePhotoShortcut"),
            object: nil
        )
    }
    
    private func handleOpenCameraShortcut() {
        print("🎤 Siri shortcut: Abriendo cámara")
        
        // Notificar a la app principal que debe abrir la cámara
        NotificationCenter.default.post(
            name: NSNotification.Name("SiriOpenCameraShortcut"),
            object: nil
        )
    }
    
    // MARK: - Funciones de utilidad para Shortcuts
    
    func donateShortcutActivity(for action: String) {
        let userActivity = NSUserActivity(activityType: "com.beme.\(action)")
        userActivity.title = action == "takephoto" ? "Tomar foto con BeMe" : "Abrir BeMe"
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPrediction = true
        userActivity.persistentIdentifier = "com.beme.\(action)"
        userActivity.suggestedInvocationPhrase = action == "takephoto" ? "Tomar foto con BeMe" : "Abrir BeMe"
        
        // Agregar metadata
        userActivity.userInfo = ["action": action]
        
        // Hacer la actividad actual
        userActivity.becomeCurrent()
    }
    
    func createShortcutSuggestion() -> INShortcut? {
        let activity = NSUserActivity(activityType: "com.beme.takephoto")
        activity.title = "Tomar foto con BeMe"
        activity.suggestedInvocationPhrase = "Tomar foto espontánea"
        activity.userInfo = ["action": "takephoto"]
        activity.isEligibleForPrediction = true
        
        return INShortcut(userActivity: activity)
    }
}

// MARK: - Extension para facilitar el uso

extension SiriShortcutsManager {
    
    func presentShortcutSettings(from viewController: UIViewController) {
        guard let shortcut = createShortcutSuggestion() else { return }
        
        let shortcutViewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        shortcutViewController.delegate = SiriShortcutDelegate.shared
        
        viewController.present(shortcutViewController, animated: true)
    }
}

// MARK: - Delegate para manejar la configuración de shortcuts

class SiriShortcutDelegate: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
    static let shared = SiriShortcutDelegate()
    
    private override init() {
        super.init()
    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true)
        
        if let error = error {
            print("❌ Error adding voice shortcut: \(error)")
        } else if voiceShortcut != nil {
            print("✅ Voice shortcut added successfully")
        }
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}
