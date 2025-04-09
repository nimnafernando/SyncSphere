//
//  ProgressView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

struct CustomProgressBar: View {
    let progress: CGFloat = 0.65

    var body: some View {
        VStack(alignment: .leading) {
            Text("65% progress")
                .padding(.leading, 20)

            ZStack(alignment: .leading) {
                // Outer border with gradient
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [Color.Lavendar, Color.CustomPink, Color.SystemBeige],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                    )
                    .frame(height: 40)

                // Filled gradient progress bar
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [Color.Lavendar, Color.CustomPink, Color.SystemBeige],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressBarWidth(proxyWidth: UIScreen.main.bounds.width - 46), height: 30)
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
            }
            .padding(.horizontal, 20)
        }
    }

    private func progressBarWidth(proxyWidth: CGFloat) -> CGFloat {
        return proxyWidth * progress
    }
}

#Preview {
    CustomProgressBar()
}
