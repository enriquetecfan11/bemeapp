//
//  ContentView.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//


import SwiftUI
import AVFoundation
import Intents
import Combine

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
    @State private var showSettings = false
    @State private var showProfile = false
    @State private var siriShortcutObserver: NSObjectProtocol?
    
    // Settings
    @AppStorage("captureDelay") private var captureDelay: Double = 0.0
    @AppStorage("enableHapticFeedback") private var enableHapticFeedback: Bool = true

    var body: some View {
        ZStack {
            // Fondo de cámara con gradiente
            if cameraManager.cameraPermissionGranted {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                    .overlay(
                        // Gradiente sutil para mejor legibilidad
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.black.opacity(0.3), location: 0.0),
                                .init(color: Color.clear, location: 0.3),
                                .init(color: Color.clear, location: 0.7),
                                .init(color: Color.black.opacity(0.4), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                            .ignoresSafeArea()
                        .opacity(showInstructions && !isProximityDetected ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: showInstructions)
                    )
            } else {
                // Fondo elegante para permisos
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.gray.opacity(0.8),
                Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                    .ignoresSafeArea()
            }
            
            // Overlay de captura
            if isProximityDetected {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(overlayOpacity)
                    
                    // Efectos de captura modernos
                    if isCapturing {
                        VStack(spacing: 30) {
                            // Anillo pulsante principal
                            ZStack {
                                // Anillo exterior
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(pulseScale * 1.2)
                                
                                // Anillo interior
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(pulseScale)
                                
                                // Centro
                        Circle()
                            .fill(Color.white)
                                    .frame(width: 40, height: 40)
                            }
                            .animation(
                                Animation.easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true),
                                value: pulseScale
                            )
                            
                            // Texto de captura
                            Text("Capturando...")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .opacity(pulseScale > 0.9 ? 1.0 : 0.6)
                                .animation(.easeInOut(duration: 0.8), value: pulseScale)
                        }
                    }
                    
                    // Animación de éxito mejorada
                    if showSuccessCheck {
                        VStack(spacing: 20) {
                        ZStack {
                                // Círculo de fondo con gradiente
                            Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.green.opacity(0.8),
                                                Color.green
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                // Checkmark con sombra
                                Image(systemName: "checkmark")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.2), radius: 2)
                            }
                            .scaleEffect(showSuccessCheck ? 1.0 : 0.2)
                            .opacity(showSuccessCheck ? 1.0 : 0.0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1),
                                value: showSuccessCheck
                            )
                            
                            Text("¡Foto capturada!")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(showSuccessCheck ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.3).delay(0.2), value: showSuccessCheck)
                        }
                    }
                }
            }
            
                        // Interfaz principal rediseñada
            VStack(spacing: 0) {
                // Header centrado solo con logo
                HStack {
                    Spacer()
                    
                    // Logo BeMe rediseñado y centrado
                    VStack(spacing: 2) {
                        Text("BeMe")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Línea decorativa
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 30, height: 1)
                    }
                    .opacity(showInstructions && !isProximityDetected ? 1.0 : 0.7)
                    .animation(.easeInOut(duration: 0.4), value: showInstructions)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Contenido principal
                if let errorMessage = cameraManager.errorMessage {
                    ErrorView(message: errorMessage)
                } else if !cameraManager.cameraPermissionGranted {
                    PermissionView()
                } else if showInstructions && !isProximityDetected {
                    InstructionsView(
                        handIconPulse: $handIconPulse,
                        statusDots: $statusDots,
                        statusOpacity: $statusOpacity,
                        instructionsPanelScale: $instructionsPanelScale,
                        instructionsPanelOpacity: $instructionsPanelOpacity,
                        onAppear: startInstructionsAnimation
                    )
                }
                
                Spacer()
            }
            
            // Top overlays: Stats (left) + Settings (right)
            VStack {
                HStack {
                    // Stats badge (top-left)
                    if cameraManager.cameraPermissionGranted {
                        StatsBadgeView(
                            today: cameraManager.todayPhotoCount,
                            week: cameraManager.weekPhotoCount,
                            total: cameraManager.totalPhotoCountPublished,
                            session: cameraManager.sessionPhotoCount
                        )
                        .opacity(showInstructions && !isProximityDetected ? 1.0 : 0.85)
                        .animation(.easeInOut(duration: 0.4), value: showInstructions)
                    }
                    
                    Spacer()
                    
                    // Profile button
                    Button(action: {
                        if enableHapticFeedback {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                        showProfile = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .opacity(showInstructions && !isProximityDetected ? 1.0 : 0.7)
                    .scaleEffect(showInstructions && !isProximityDetected ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 0.4), value: showInstructions)
                    
                    // Spacing between profile and settings
                    Spacer().frame(width: 12)
                    
                    // Settings button (top-right)
                    Button(action: {
                        if enableHapticFeedback {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                        showSettings = true
                    }) {
                        ZStack {
                            // Background con blur
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                )
                                .shadow(
                                    color: Color.black.opacity(0.2),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            
                            // Icono de engranaje
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .opacity(showInstructions && !isProximityDetected ? 1.0 : 0.7)
                    .scaleEffect(showInstructions && !isProximityDetected ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 0.4), value: showInstructions)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60) // Safe area + margin
                
                Spacer()
            }

            // Floating Action Button para configuración (legacy positioning, removed to avoid duplication)
        }
        .onAppear {
            setupCamera()
            setupProximitySensor()
            setupSiriShortcuts()
        }
        .onDisappear {
            cleanupProximitySensor()
            cleanupSiriShortcuts()
            cameraManager.stopSession()
        }
        .animation(.easeInOut(duration: 0.4), value: isProximityDetected)
        .fullScreenCover(isPresented: $cameraManager.showPhotoPreview) {
            // Nueva vista de post-captura rediseñada
            PostCaptureOverlay(
                isPresented: $cameraManager.showPhotoPreview,
                capturedImage: cameraManager.capturedImage,
                onSave: {
                    cameraManager.savePhotoToGallery()
                },
                onDiscard: {
                    cameraManager.discardPhoto()
                },
                onShare: {
                    if let image = cameraManager.capturedImage {
                        shareImage(image)
                    }
                }
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(sessionCount: cameraManager.sessionPhotoCount)
        }
        .onChange(of: showSettings) { _, isShowing in
            if isShowing {
                // Deshabilitar sensor de proximidad cuando se abre Settings
                UIDevice.current.isProximityMonitoringEnabled = false
                print("🔧 Sensor de proximidad deshabilitado (Settings abierto)")
            } else {
                // Rehabilitar sensor de proximidad cuando se cierra Settings
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if cameraManager.cameraPermissionGranted && !showSettings {
                        UIDevice.current.isProximityMonitoringEnabled = true
                        print("📱 Sensor de proximidad rehabilitado (Settings cerrado)")
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Rehabilitar sensor cuando la app vuelve del fondo
            if cameraManager.cameraPermissionGranted && !showSettings {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    UIDevice.current.isProximityMonitoringEnabled = true
                    print("📱 Sensor de proximidad rehabilitado (app en primer plano)")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            // Deshabilitar sensor cuando la app va al fondo
            UIDevice.current.isProximityMonitoringEnabled = false
            print("📱 Sensor de proximidad deshabilitado (app en segundo plano)")
        }
        .shareBanner(image: cameraManager.capturedImage ?? UIImage(), isVisible: $cameraManager.showShareBanner)
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
        guard cameraManager.cameraPermissionGranted else { return }
        
        UIDevice.current.isProximityMonitoringEnabled = true
        print("📱 Sensor de proximidad habilitado")
        
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
            if enableHapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            }
            
            // Iniciar la animación del círculo pulsante después del fade
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isCapturing = true
                pulseScale = 0.8
                
                // Tomar foto después de que comience la animación
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    cameraManager.takePhoto()
                    
                    // Donar actividad de Siri para futuras sugerencias
                    SiriShortcutsManager.shared.donateShortcutActivity(for: "takephoto")
                    
                    // Mostrar check de éxito después de la captura
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // Feedback háptico de éxito
                        if enableHapticFeedback {
                        let successFeedback = UINotificationFeedbackGenerator()
                        successFeedback.notificationOccurred(.success)
                        }
                        
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
        print("📱 Sensor de proximidad deshabilitado")
    }
    
    // MARK: - Siri Shortcuts
    
    private func setupSiriShortcuts() {
        // Configurar shortcuts
        SiriShortcutsManager.shared.setupShortcuts()
        
        // Observar notificaciones de shortcuts
        siriShortcutObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SiriTakePhotoShortcut"),
            object: nil,
            queue: .main
        ) { _ in
            handleSiriTakePhotoShortcut()
        }
    }
    
    private func cleanupSiriShortcuts() {
        if let observer = siriShortcutObserver {
            NotificationCenter.default.removeObserver(observer)
            siriShortcutObserver = nil
        }
    }
    
    private func handleSiriTakePhotoShortcut() {
        print("🎤 Manejando shortcut de Siri: Tomar foto")
        
        // Simular proximidad para activar la captura
        if !isProximityDetected {
            isProximityDetected = true
            showInstructions = false
            
            // Animación del overlay
            withAnimation(.easeInOut(duration: 0.4)) {
                overlayOpacity = 1.0
            }
            
            // Feedback háptico
            if enableHapticFeedback {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            
            // Captura automática después de un breve delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isCapturing = true
                pulseScale = 0.8
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    cameraManager.takePhoto()
                    
                    // Donar actividad para futuras sugerencias de Siri
                    SiriShortcutsManager.shared.donateShortcutActivity(for: "takephoto")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if enableHapticFeedback {
                            let successFeedback = UINotificationFeedbackGenerator()
                            successFeedback.notificationOccurred(.success)
                        }
                        
                        isCapturing = false
                        showSuccessCheck = true
                        
                        // Reset después de mostrar éxito
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showSuccessCheck = false
                            
                            withAnimation(.easeOut(duration: 0.3)) {
                                overlayOpacity = 0.0
                                isProximityDetected = false
                            }
                            
                            pulseScale = 1.0
                            instructionsPanelScale = 0.8
                            instructionsPanelOpacity = 0.0
                            handIconPulse = 1.0
                            statusOpacity = 0.0
                            statusDots = ""
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showInstructions = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Funciones de Utilidad
    
    private func shareImage(_ image: UIImage) {
        // Feedback háptico
        if enableHapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        // Obtener el view controller actual
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // Crear el activity view controller
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // Configurar para iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Presentar el sheet
        rootViewController.present(activityViewController, animated: true)
    }
}

// MARK: - Vista Full-Screen de Post-Captura Rediseñada
struct PostCaptureOverlay: View {
    @Binding var isPresented: Bool
    let capturedImage: UIImage?
    let onSave: () -> Void
    let onDiscard: () -> Void
    let onShare: () -> Void
    
    @State private var showPanel = false
    @State private var discardPressed = false
    @State private var savePressed = false
    @State private var sharePressed = false
    @AppStorage("enableHapticFeedback") private var enableHapticFeedback: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo difuminado que cubre toda la pantalla
                Color.black
                    .opacity(0.6)
                    .blur(radius: 20)
                    .ignoresSafeArea()
                
                // Panel central integrado
                if showPanel, let image = capturedImage {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Panel principal que ocupa 90% del alto
                        VStack(spacing: 32) {
                            // Miniatura con borde semitransparente y sombra
                            VStack(spacing: 24) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: min(geometry.size.width * 0.75, 320), height: min(geometry.size.width * 0.75, 320))
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                    .shadow(
                                        color: Color.black.opacity(0.4),
                                        radius: 20,
                                        x: 0,
                                        y: 10
                                    )
                                
                                // Texto de confirmación
                                VStack(spacing: 8) {
                                    Text("¡Foto capturada!")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("¿Qué quieres hacer con esta foto?")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            Spacer()
                            
                            // VStack de botones con mejor proporción
                            VStack(spacing: 16) {
                                // Fila superior con Descartar y Guardar
                                HStack(spacing: 16) {
                                    // Botón Descartar
                                    Button(action: {
                                        handleAction {
                                            onDiscard()
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 16, weight: .medium))
                                            
                                            Text("Descartar")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.red.opacity(0.8),
                                                            Color.red
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .shadow(
                                            color: Color.red.opacity(0.4),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                    }
                                    .scaleEffect(discardPressed ? 0.95 : 1.0)
                                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            discardPressed = pressing
                                        }
                                    }, perform: {})
                                    
                                    // Botón Guardar
                                    Button(action: {
                                        handleAction {
                                            onSave()
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16, weight: .medium))
                                            
                                            Text("Guardar")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.green.opacity(0.8),
                                                            Color.green
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .shadow(
                                            color: Color.green.opacity(0.4),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                    }
                                    .scaleEffect(savePressed ? 0.95 : 1.0)
                                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            savePressed = pressing
                                        }
                                    }, perform: {})
                                }
                                
                                // Botón Compartir centrado abajo
                                Button(action: {
                                    handleAction {
                                        onShare()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Text("Compartir")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.blue.opacity(0.8),
                                                        Color.blue
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .shadow(
                                        color: Color.blue.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                                }
                                .scaleEffect(sharePressed ? 0.95 : 1.0)
                                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        sharePressed = pressing
                                    }
                                }, perform: {})
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.gray.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(
                                    color: Color.black.opacity(0.3),
                                    radius: 20,
                                    x: 0,
                                    y: 10
                                )
                        )
                        .frame(height: geometry.size.height * 0.9)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            showPanelWithAnimation()
        }
    }
    
    private func showPanelWithAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showPanel = true
        }
    }
    
    private func dismissPanel() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showPanel = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    private func handleAction(_ action: @escaping () -> Void) {
        if enableHapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        dismissPanel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            action()
        }
    }
}

// MARK: - Vista de Error
struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(message)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 32)
    }
}

// MARK: - Vista de Permisos
struct PermissionView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Icono principal
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.1),
                                Color.blue.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text("Acceso a Cámara")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("BeMe necesita acceso a la cámara para capturar fotos espontáneas.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                
                VStack(spacing: 8) {
                    Text("Ve a Configuración")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 4) {
                        Text("Privacidad")
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                        Text("Cámara")
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                        Text("BeMe")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 32)
    }
}

// MARK: - Vista de Instrucciones
struct InstructionsView: View {
    @Binding var handIconPulse: CGFloat
    @Binding var statusDots: String
    @Binding var statusOpacity: Double
    @Binding var instructionsPanelScale: CGFloat
    @Binding var instructionsPanelOpacity: Double
    let onAppear: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                // Panel principal rediseñado - limitado al 70% de altura
                VStack(spacing: 28) {
                    // Icono principal mejorado - más compacto
                    ZStack {
                        // Círculos de pulso múltiples
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(Color.white.opacity(0.08), lineWidth: 1.5)
                                .frame(width: 70 + CGFloat(index * 15), height: 70 + CGFloat(index * 15))
                                .scaleEffect(handIconPulse + CGFloat(index) * 0.08)
                                .animation(
                                    Animation.easeInOut(duration: 2.0 + Double(index) * 0.2)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.1),
                                    value: handIconPulse
                                )
                        }
                        
                        // Icono central
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(handIconPulse > 1.05 ? 1.03 : 1.0)
                        .animation(.easeInOut(duration: 2.0), value: handIconPulse)
                    }
                    
                    // Texto principal - más compacto
                    VStack(spacing: 16) {
                        Text("Acerca el teléfono")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Cubre el sensor de proximidad para capturar")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                        
                        // Tags informativos - en 2 filas si es necesario
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                ForEach(["Sin filtros", "Sin vista previa"], id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Color.white.opacity(0.1))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                                )
                                        )
                                }
                            }
                            
                            Text("Momento real")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                        )
                                )
                        }
                    }
                    
                    // Estado de espera - más discreto
                    VStack(spacing: 10) {
                        Capsule()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 50, height: 1.5)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                                .opacity(statusOpacity)
                            
                            Text("Listo\(statusDots)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .opacity(statusOpacity)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.08),
                                            Color.white.opacity(0.15)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.8
                                )
                        )
                )
                .frame(maxHeight: geometry.size.height * 0.7) // Limitado al 70% de altura
                .scaleEffect(instructionsPanelScale)
                .opacity(instructionsPanelOpacity)
                .onAppear(perform: onAppear)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 28)
    }
}
