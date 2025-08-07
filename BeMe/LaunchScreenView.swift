//
//  LaunchScreenView.swift
//  BeMe
//
//  Created by Kike Rodriguez Vela on 6/8/25.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var logoScale: CGFloat = 0.0
    @State private var logoOpacity: Double = 0.0
    @State private var titleOpacity: Double = 0.0
    @State private var titleScale: CGFloat = 0.8
    @State private var subtitleOpacity: Double = 0.0
    @State private var loaderOpacity: Double = 0.0
    @State private var cameraHeartbeat: CGFloat = 1.0
    @State private var backgroundPulse: CGFloat = 1.0
    @State private var loadingProgress: CGFloat = 0.0
    @State private var showMainApp = false
    
    var body: some View {
        ZStack {
            // Fondo con radial gradient sutil
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                // Gradiente radial sutil para profundidad
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.08).opacity(0.8),
                        Color.black,
                        Color.black
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
                .ignoresSafeArea()
                .scaleEffect(backgroundPulse)
                .animation(
                    Animation.easeInOut(duration: 4.0)
                        .repeatForever(autoreverses: true),
                    value: backgroundPulse
                )
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Ícono de cámara con latido emocional
                ZStack {
                    // Aura de pulso exterior
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.05),
                                    Color.white.opacity(0.02),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(cameraHeartbeat * 1.2)
                        .opacity(logoOpacity * 0.6)
                    
                    // Círculo de resplandor medio
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(cameraHeartbeat)
                        .opacity(logoOpacity * 0.8)
                    
                    // Ícono de cámara con latido
                    ZStack {
                        // Cuerpo de la cámara
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .frame(width: 56, height: 40)
                            .shadow(color: Color.white.opacity(0.3), radius: 8, x: 0, y: 0)
                        
                        // Lente principal
                        Circle()
                            .fill(Color.black)
                            .frame(width: 24, height: 24)
                        
                        // Reflejo del lente
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 8, height: 8)
                            .offset(x: -2, y: -2)
                        
                        // Flash
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white)
                            .frame(width: 10, height: 7)
                            .offset(x: -18, y: -14)
                            .shadow(color: Color.white.opacity(0.5), radius: 2, x: 0, y: 0)
                    }
                    .scaleEffect(cameraHeartbeat)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // Título con animación emocional
                VStack(spacing: 12) {
                    Text("BeMe")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(titleOpacity)
                        .scaleEffect(titleScale)
                        .shadow(color: Color.white.opacity(0.3), radius: 8, x: 0, y: 0)
                    
                    Text("Momentos espontáneos, auténticos")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                        .opacity(subtitleOpacity)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                
                Spacer()
                
                // Loader sincronizado con el latido del corazón
                VStack(spacing: 20) {
                    // Barra de progreso circular emocional
                    ZStack {
                        // Círculo base
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 3)
                            .frame(width: 60, height: 60)
                        
                        // Progreso animado
                        Circle()
                            .trim(from: 0, to: loadingProgress)
                            .stroke(
                                Color.white.opacity(0.6),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .scaleEffect(cameraHeartbeat * 0.98)
                        
                        // Punto central pulsante
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .scaleEffect(cameraHeartbeat)
                    }
                    .opacity(loaderOpacity)
                    
                    // Texto de estado
                    VStack(spacing: 4) {
                        Text("Despertando la cámara...")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("Preparando momentos auténticos")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .opacity(loaderOpacity)
                    .multilineTextAlignment(.center)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startLaunchAnimation()
        }
        .fullScreenCover(isPresented: $showMainApp) {
            ContentView()
        }
    }
    
    private func startLaunchAnimation() {
        // Iniciar el pulso de fondo inmediatamente
        backgroundPulse = 1.05
        
        // 1. Aparición del ícono con efecto spring emocional
        withAnimation(.spring(response: 1.2, dampingFraction: 0.7, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Iniciar el latido del corazón de la cámara
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            startCameraHeartbeat()
        }
        
        // 2. Título aparece con escala y fade emocional
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
        }
        
        // 3. Subtítulo con fade suave
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.8)) {
                subtitleOpacity = 1.0
            }
        }
        
        // 4. Loader aparece sincronizado
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeIn(duration: 0.6)) {
                loaderOpacity = 1.0
            }
            startLoadingProgress()
        }
        
        // Transición a la app principal
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showMainApp = true
            }
        }
    }
    
    private func startCameraHeartbeat() {
        withAnimation(
            Animation.easeInOut(duration: 1.8)
                .repeatForever(autoreverses: true)
        ) {
            cameraHeartbeat = 1.15
        }
    }
    
    private func startLoadingProgress() {
        withAnimation(.easeInOut(duration: 2.2)) {
            loadingProgress = 1.0
        }
    }
}

#Preview {
    LaunchScreenView()
}

