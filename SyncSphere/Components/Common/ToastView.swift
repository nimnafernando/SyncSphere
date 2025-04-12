//
//  ToastView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-08.
//

import SwiftUI

enum ToastType {
    case success
    case error

    var backgroundColor: Color {
        switch self {
        case .success:
            return Color.green.opacity(0.9)
        case .error:
            return Color.red.opacity(0.9)
        }
    }

    var icon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.octagon.fill"
        }
    }
}

struct ToastView: View {
    let message: String
        let type: ToastType

        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: type.icon)
                    .foregroundColor(.white)
                Text(message)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(type.backgroundColor)
            .cornerRadius(10)
            .shadow(radius: 4)
            .padding(.horizontal)
        }
}

#Preview {
    ToastView(message: "Message here", type: .success)
}
