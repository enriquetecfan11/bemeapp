//
//  SettingsView.swift
//  BeMe
//
//  Created by Assistant on 6/8/25.
//

import SwiftUI
import IntentsUI

struct SettingsView: View {
    @AppStorage("captureDelay") private var captureDelay: Double = 0.0
    @AppStorage("showShareBanner") private var showShareBanner: Bool = true
    @AppStorage("enableHapticFeedback") private var enableHapticFeedback: Bool = true
    @AppStorage("showWatermark") private var showWatermark: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    private let delayOptions: [Double] = [0.0, 0.5, 1.0]
    private let delayLabels: [Double: String] = [
        0.0: "Inmediato",
        0.5: "0.5 segundos",
        1.0: "1 segundo"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // Sección de Captura
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Retardo de Captura")
                                .font(.headline)
                        }
                        
                        Text("Tiempo de espera antes de tomar la foto para ajustar el encuadre")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Retardo", selection: $captureDelay) {
                            ForEach(delayOptions, id: \.self) { delay in
                                Text(delayLabels[delay] ?? "\(delay)s")
                                    .tag(delay)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: captureDelay) { _, _ in
                            // Feedback háptico al cambiar configuración
                            if enableHapticFeedback {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Configuración de Captura")
                }
                
                // Sección de Compartir
                Section {
                    Toggle(isOn: $showShareBanner) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Banner de Compartir")
                                    .font(.headline)
                                Text("Mostrar opciones para compartir después de guardar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onChange(of: showShareBanner) { _, _ in
                        if enableHapticFeedback {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                    
                    Toggle(isOn: $showWatermark) {
                        HStack {
                            Image(systemName: "textformat")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Marca de Agua BeMe")
                                    .font(.headline)
                                Text("Agregar logo BeMe a las fotos capturadas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onChange(of: showWatermark) { _, _ in
                        if enableHapticFeedback {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                } header: {
                    Text("Compartir y Marca de Agua")
                }
                
                // Sección de Experiencia
                Section {
                    Toggle(isOn: $enableHapticFeedback) {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Vibración Háptica")
                                    .font(.headline)
                                Text("Feedback físico durante las interacciones")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Experiencia de Usuario")
                }
                
                // Sección de Información
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        // Estadísticas del álbum
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Álbum BeMe")
                                    .font(.headline)
                                Text("Las fotos se guardan automáticamente en un álbum dedicado")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        // Información sobre Siri Shortcuts
                        Button(action: {
                            addSiriShortcut()
                        }) {
                            HStack {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Configurar Atajo de Siri")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Añadir comando de voz personalizado")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Información")
                }
                
                // Sección de versión
                Section {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("BeMe")
                        Spacer()
                        Text("Fotos espontáneas sin filtros")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                } header: {
                    Text("Acerca de")
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func addSiriShortcut() {
        // Obtener el view controller actual
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // Presentar el configurador de shortcuts de Siri
        SiriShortcutsManager.shared.presentShortcutSettings(from: rootViewController)
    }
}

#Preview {
    SettingsView()
}