//
//  ContentView.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//


import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var proximityObserver: NSObjectProtocol?
    @State private var isProximityDetected = false
    @State private var showInstructions = true
    @State private var isCapturing = false
    @State private var showSuccessCheck = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var overlayOpacity: Double = 0.0
    @State private var instructionsPanelScale: CGFloat = 0.8
    @State private var instructionsPanelOpacity: Double = 0.0
    @State private var handIconPulse: CGFloat = 1.0
    @State private var statusDots = ""
    @State private var statusOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Vista de cámara
            if cameraManager.cameraPermissionGranted {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                    .overlay(
                        // Overlay sutil para enfocar atención en las instrucciones
                        Color.black.opacity(showInstructions && !isProximityDetected ? 0.2 : 0.0)
                            .ignoresSafeArea()
                            .animation(.easeInOut(duration: 0.3), value: showInstructions)
                    )
            } else {
                // Pantalla de permisos
                Color.black
                    .ignoresSafeArea()
            }
            
            // Overlay oscuro con animación suave cuando se detecta proximidad
            if isProximityDetected {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(overlayOpacity)
                    
                    // Círculo pulsante durante la captura
                    if isCapturing {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                            .scaleEffect(pulseScale)
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true),
                                value: pulseScale
                            )
                    }
                    
                    // Check verde de éxito
                    if showSuccessCheck {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(showSuccessCheck ? 1.0 : 0.3)
                        .opacity(showSuccessCheck ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0),
                            value: showSuccessCheck
                        )
                    }
                }
            }
            
            // Contenido de la interfaz
            VStack {
                // Branding BeMe en la parte superior
                HStack {
                    Spacer()
                    Text("BeMe")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .opacity(showInstructions && !isProximityDetected ? 0.8 : 0.4)
                        .animation(.easeInOut(duration: 0.3), value: showInstructions)
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                if let errorMessage = cameraManager.errorMessage {
                    Text(errorMessage)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
                if !cameraManager.cameraPermissionGranted {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        Text("Permiso de Cámara Requerido")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("BeMe necesita acceso a la cámara para capturar fotos espontáneas. Ve a Configuración > Privacidad > Cámara y habilita el acceso para BeMe.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    .padding()
                } else if showInstructions && !isProximityDetected {
                    // Panel de instrucciones elegante y minimalista
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            
                            ZStack {
                                // Fondo principal con blur y drop shadow
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.ultraThinMaterial.opacity(0.6))
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.black.opacity(0.2))
                                    )
                                    .overlay(
                                        // Gradient stroke elegante
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.1),
                                                        Color.white.opacity(0.3),
                                                        Color.white.opacity(0.1)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                    .overlay(
                                        // Inner shadow para volumen
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                            .blur(radius: 1)
                                            .offset(x: 1, y: 1)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .fill(LinearGradient(
                                                        gradient: Gradient(colors: [Color.clear, Color.black]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ))
                                            )
                                    )
                                    .shadow(
                                        color: Color.black.opacity(0.2),
                                        radius: 4,
                                        x: 0,
                                        y: 2
                                    )
                                
                                VStack(spacing: 20) {
                                    // Icono de mano animado
                                    ZStack {
                                        // Círculo de pulso de fondo
                                        Circle()
                                            .fill(Color.white.opacity(0.04))
                                            .frame(width: 90, height: 90)
                                            .scaleEffect(handIconPulse)
                                            .animation(
                                                Animation.easeInOut(duration: 2.0)
                                                    .repeatForever(autoreverses: true),
                                                value: handIconPulse
                                            )
                                        
                                        Image(systemName: "hand.raised.fill")
                                            .font(.system(size: 48, weight: .regular))
                                            .foregroundColor(.white)
                                            .scaleEffect(handIconPulse > 1.05 ? 1.04 : 1.0)
                                            .animation(
                                                Animation.easeInOut(duration: 2.0)
                                                    .repeatForever(autoreverses: true),
                                                value: handIconPulse
                                            )
                                    }
                                    
                                    VStack(spacing: 14) {
                                        // Título principal
                                        Text("Acerca el teléfono a tu pecho")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .dynamicTypeSize(.large...(.accessibility1))
                                        
                                        // Descripción
                                        Text("Cubre el sensor de proximidad para capturar una foto espontánea con la cámara trasera")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.85))
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(1.5)
                                            .dynamicTypeSize(.medium...(.accessibility1))
                                        
                                        // Subtítulo
                                        Text("Sin vista previa • Sin filtros • Solo el momento real")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white.opacity(0.65))
                                            .multilineTextAlignment(.center)
                                            .dynamicTypeSize(.small...(.large))
                                    }
                                    
                                    // Indicador de estado animado
                                    VStack(spacing: 6) {
                                        // Línea separadora refinada
                                        Capsule()
                                            .fill(Color.white.opacity(0.25))
                                            .frame(width: 50, height: 1)
                                        
                                        // Estado de espera
                                        Text("Esperando activación\(statusDots)")
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white.opacity(0.5))
                                            .opacity(statusOpacity)
                                    }
                                }
                                .padding(.vertical, 24)
                                .padding(.horizontal, 16)
                            }
                            .frame(width: geometry.size.width * 0.8)
                            .scaleEffect(instructionsPanelScale)
                            .opacity(instructionsPanelOpacity)
                            .onAppear {
                                startInstructionsAnimation()
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            setupCamera()
            setupProximitySensor()
        }
        .onDisappear {
            cleanupProximitySensor()
            cameraManager.stopSession()
        }
        .animation(.easeInOut(duration: 0.4), value: isProximityDetected)
        .fullScreenCover(isPresented: $cameraManager.showPhotoPreview) {
            if let capturedImage = cameraManager.capturedImage {
                PhotoPreviewView(
                    image: capturedImage,
                    onSave: {
                        cameraManager.savePhotoToGallery()
                    },
                    onDiscard: {
                        cameraManager.discardPhoto()
                    }
                )
            }
        }
    }
    
    private func startInstructionsAnimation() {
        // Animación de entrada del panel
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
            instructionsPanelScale = 1.0
            instructionsPanelOpacity = 1.0
        }
        
        // Iniciar animación del icono de mano
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            handIconPulse = 1.1
        }
        
        // Mostrar indicador de estado con delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.4)) {
                statusOpacity = 1.0
            }
            startStatusDotsAnimation()
        }
    }
    
    private func startStatusDotsAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.3)) {
                switch statusDots.count {
                case 0:
                    statusDots = "."
                case 1:
                    statusDots = ".."
                case 2:
                    statusDots = "..."
                default:
                    statusDots = ""
                }
            }
            
            // Detener el timer si ya no se muestran las instrucciones
            if !showInstructions || isProximityDetected {
                timer.invalidate()
                statusDots = ""
            }
        }
    }
    
    private func setupCamera() {
        cameraManager.startSession()
    }
    
    private func setupProximitySensor() {
        UIDevice.current.isProximityMonitoringEnabled = true
        
        proximityObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.proximityStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleProximityChange()
        }
    }
    
    private func handleProximityChange() {
        if UIDevice.current.proximityState {
            print("📱 Sensor detecta algo cerca - Capturando foto espontánea")
            isProximityDetected = true
            showInstructions = false
            
            // Animación suave del fade in hacia negro
            withAnimation(.easeInOut(duration: 0.4)) {
                overlayOpacity = 1.0
            }
            
            // Feedback háptico ligero
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Iniciar la animación del círculo pulsante después del fade
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isCapturing = true
                pulseScale = 0.8
                
                // Tomar foto después de que comience la animación
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    cameraManager.takePhoto()
                    
                    // Mostrar check de éxito después de la captura
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // Feedback háptico de éxito
                        let successFeedback = UINotificationFeedbackGenerator()
                        successFeedback.notificationOccurred(.success)
                        
                        isCapturing = false
                        showSuccessCheck = true
                        
                        // Ocultar el check después de un momento
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            showSuccessCheck = false
                        }
                    }
                }
            }
        } else {
            print("📱 Sensor ya no detecta proximidad")
            
            // Reset de estados
            withAnimation(.easeOut(duration: 0.3)) {
                overlayOpacity = 0.0
                isProximityDetected = false
            }
            
            isCapturing = false
            showSuccessCheck = false
            pulseScale = 1.0
            
            // Reset de estados de instrucciones
            instructionsPanelScale = 0.8
            instructionsPanelOpacity = 0.0
            handIconPulse = 1.0
            statusOpacity = 0.0
            statusDots = ""
            
            // Mostrar instrucciones nuevamente después de un delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showInstructions = true
            }
        }
    }
    
    private func cleanupProximitySensor() {
        if let observer = proximityObserver {
            NotificationCenter.default.removeObserver(observer)
            proximityObserver = nil
        }
        UIDevice.current.isProximityMonitoringEnabled = false
    }
}
