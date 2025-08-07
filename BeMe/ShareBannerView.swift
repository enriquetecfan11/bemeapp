//
//  ShareBannerView.swift
//  BeMe
//
//  Created by Assistant on 6/8/25.
//

import SwiftUI
import UIKit

struct ShareBannerView: View {
    let image: UIImage
    @Binding var isVisible: Bool
    @State private var bannerOffset: CGFloat = 100
    @State private var bannerOpacity: Double = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            if isVisible {
                HStack(spacing: 16) {
                    // Thumbnail de la imagen
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Foto guardada en BeMe")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("¿Quieres compartirla?")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Botón de compartir
                    Button(action: shareImage) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Botón de cerrar
                    Button(action: dismissBanner) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 30, height: 30)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.8))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Espacio desde el bottom
                .offset(y: bannerOffset)
                .opacity(bannerOpacity)
                .onAppear {
                    showBanner()
                    
                    // Auto-dismiss después de 5 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        if isVisible {
                            dismissBanner()
                        }
                    }
                }
                .onTapGesture {
                    shareImage()
                }
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: bannerOffset)
        .animation(.easeInOut(duration: 0.3), value: bannerOpacity)
    }
    
    private func showBanner() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            bannerOffset = 0
            bannerOpacity = 1
        }
    }
    
    private func dismissBanner() {
        withAnimation(.easeInOut(duration: 0.3)) {
            bannerOffset = 100
            bannerOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isVisible = false
        }
    }
    
    private func shareImage() {
        // Feedback háptico
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
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
        
        // Dismiss el banner después de mostrar el sheet
        dismissBanner()
    }
}

// MARK: - Vista de extensión para manejo de sharing

extension View {
    func shareBanner(image: UIImage, isVisible: Binding<Bool>) -> some View {
        self.overlay(
            ShareBannerView(image: image, isVisible: isVisible)
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ShareBannerView(
            image: UIImage(systemName: "photo") ?? UIImage(),
            isVisible: .constant(true)
        )
    }
}
