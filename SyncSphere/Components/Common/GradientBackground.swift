//
//  GradientBackground.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-18.
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
        // Gradient Circle 1
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [Color.CustomPink.opacity(0.5), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 250
                )
            )
            .frame(width: 500, height: 500)
            .position(x: 200, y: 250)
        
        // Gradient Circle 2
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [Color.Lavendar.opacity(0.3), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .frame(width: 450, height: 450)
            .position(x: 30, y: 560)
        
        // Gradient Circle 3
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [Color.SystemBeige, Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 250
                )
            )
            .frame(width: 500, height: 530)
            .position(x: 320, y: 600)
    }
}

#Preview {
    GradientBackground()
}
