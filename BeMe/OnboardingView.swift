//
//  OnboardingView.swift
//  BeMe
//
//  Created by AI on 12/9/25.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var selection: Int = 0
    @State private var showStartButton: Bool = false
    @AppStorage("enableHapticFeedback") private var enableHapticFeedback: Bool = true
    
    var body: some View {
        ZStack {
            // Fondo
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.08, green: 0.08, blue: 0.12)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header con página
                HStack {
                    Text("BeMe")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(selection + 1)/3")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer(minLength: 0)

                TabView(selection: $selection) {
                    OnboardingPage(
                        icon: "camera.fill",
                        title: "Permisos de cámara",
                        subtitle: "BeMe necesita tu cámara para capturar momentos espontáneos.",
                        accent: .blue
                    )
                    .tag(0)

                    OnboardingPage(
                        icon: "hand.raised.fill",
                        title: "Gesto de proximidad",
                        subtitle: "Cubre el sensor de proximidad (arriba) y BeMe tomará la foto sin vista previa.",
                        accent: .green
                    )
                    .tag(1)

                    OnboardingPage(
                        icon: "photo.on.rectangle.angled",
                        title: "Guardado y compartir",
                        subtitle: "La foto se guarda y podrás compartirla enseguida si quieres.",
                        accent: .purple
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .animation(.easeInOut, value: selection)

                Spacer(minLength: 0)

                // Botón inferior
                Button(action: {
                    if enableHapticFeedback {
                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                        feedback.impactOccurred()
                    }
                    if selection < 2 {
                        selection += 1
                    } else {
                        onFinish()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(selection < 2 ? "Siguiente" : "Entendido")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

private struct OnboardingPage: View {
    let icon: String
    let title: String
    let subtitle: String
    let accent: Color

    @State private var pulse: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // Auras circulares
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulse)
                Circle()
                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulse * 1.06)

                // Icono central
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.15))
                        .frame(width: 120, height: 120)
                    Image(systemName: icon)
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.white)
                }
                .scaleEffect(pulse > 1.03 ? 1.02 : 1)
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                ) {
                    pulse = 1.06
                }
            }

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 28)
            }
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    OnboardingView { }
}

