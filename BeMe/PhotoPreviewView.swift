//
//  PhotoPreviewView.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//

import SwiftUI
import Photos

struct PhotoPreviewView: View {
    let image: UIImage
    let onSave: () -> Void
    let onDiscard: () -> Void
    @State private var showingSaveAlert = false
    @State private var isSaving = false
    @State private var viewOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Fondo negro difuminado con blur
            Color.black
                .ignoresSafeArea()
                .blur(radius: 2)
            
            VStack(spacing: 20) {
                // Branding BeMe en la parte superior
                HStack {
                    Spacer()
                    Text("BeMe")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Contenedor de la imagen con diseño flotante
                ZStack {
                    // Preview de la imagen con esquinas redondeadas y efectos
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 6,
                            x: 0,
                            y: 3
                        )
                        .padding(.horizontal, 30)
                }
                
                // Texto descriptivo con mejor spacing
                VStack(spacing: 12) {
                    Text("Foto Espontánea Capturada")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                    
                    Text("¿Quieres guardar esta foto en tu galería?")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }
                
                // Botones rediseñados con Capsule y degradados
                HStack(spacing: 16) {
                    // Botón Descartar con degradado rojo
                    Button(action: {
                        handleDiscardAction()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Descartar")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.4, blue: 0.4),
                                            Color(red: 0.9, green: 0.2, blue: 0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        .blur(radius: 1)
                                        .offset(x: 0, y: 1)
                                )
                        )
                        .shadow(
                            color: Color.red.opacity(0.3),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                    }
                    
                    // Botón Guardar con degradado verde
                    Button(action: {
                        handleSaveAction()
                    }) {
                        HStack(spacing: 8) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            Text(isSaving ? "Guardando..." : "Guardar")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            isSaving ? Color.gray.opacity(0.8) : Color(red: 0.4, green: 0.9, blue: 0.4),
                                            isSaving ? Color.gray : Color(red: 0.2, green: 0.8, blue: 0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        .blur(radius: 1)
                                        .offset(x: 0, y: 1)
                                )
                        )
                        .shadow(
                            color: isSaving ? Color.gray.opacity(0.3) : Color.green.opacity(0.3),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                    }
                    .disabled(isSaving)
                }
                
                Spacer()
            }
        }
        .opacity(viewOpacity)
        .alert("Guardar Foto", isPresented: $showingSaveAlert) {
            Button("Guardar") {
                savePhoto()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Estás seguro de que quieres guardar esta foto espontánea en tu galería?")
        }
    }
    
    private func handleDiscardAction() {
        // Feedback háptico ligero
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Transición de salida con opacity
        withAnimation(.easeOut(duration: 0.3)) {
            viewOpacity = 0.0
        }
        
        // Ejecutar la acción después de la animación
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDiscard()
        }
    }
    
    private func handleSaveAction() {
        // Feedback háptico ligero
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        showingSaveAlert = true
    }
    
    private func savePhoto() {
        isSaving = true
        
        // Usar PHPhotoLibrary directamente sin verificar permisos previamente
        // iOS solicitará automáticamente los permisos si es necesario
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            request.creationDate = Date()
        }) { success, error in
            DispatchQueue.main.async {
                isSaving = false
                if success {
                    print("✅ Foto guardada exitosamente")
                    
                    // Feedback háptico de éxito
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                    // Transición de salida con opacity
                    withAnimation(.easeOut(duration: 0.3)) {
                        viewOpacity = 0.0
                    }
                    
                    // Ejecutar la acción después de la animación
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSave()
                    }
                } else {
                    print("❌ Error guardando foto: \(error?.localizedDescription ?? "Error desconocido")")
                    
                    // Feedback háptico de error
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
} 