//
//  StatsBadgeView.swift
//  BeMe
//
//  Created by Assistant on 12/9/25.
//

import SwiftUI

struct StatsBadgeView: View {
    let today: Int
    let week: Int
    let total: Int
    let session: Int
    
    @State private var pulse: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(6)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                    )
                if session > 0 {
                    Text("\(session)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1.5)
                        .background(
                            Capsule().fill(Color.green.opacity(0.85))
                        )
                        .offset(x: 8, y: -6)
                }
            }
            
            stat(text: "Hoy", value: today)
            divider
            stat(text: "Sem", value: week)
            divider
            stat(text: "Total", value: total)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
        .scaleEffect(pulse)
        .onChange(of: today) { _, _ in bump() }
        .onChange(of: week) { _, _ in bump() }
        .onChange(of: total) { _, _ in bump() }
        .onChange(of: session) { _, _ in bump() }
    }
    
    private func stat(text: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(text)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Text("\(value)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.8)
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.2))
            .frame(width: 1, height: 16)
    }
    
    private func bump() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            pulse = 1.08
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                pulse = 1.0
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        StatsBadgeView(today: 2, week: 5, total: 20, session: 1)
    }
}
