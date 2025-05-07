//
//  ProgressView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

struct CustomProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(Int(progress * 100))% Task Completed")                .padding(.leading, 20)

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
                            .fill(Color.OffWhite)
                    )
                    .frame(height: 32)

                // Filled gradient progress bar
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [Color.Lavendar, Color.CustomPink, Color.SystemBeige],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressBarWidth(proxyWidth: UIScreen.main.bounds.width - 46), height: 22)
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
    CustomProgressBar(progress: 0.65)
}
