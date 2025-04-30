//
//  CircularProgressView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-20.
//

import SwiftUI

import Foundation
import UIKit
import QuartzCore

import SwiftUI

struct CircularProgressView: View {
    var current: Int
    var total: Int
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
    
    private var label: String {
        "\(current)/\(total)"
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 12)
                .foregroundColor(.gray.opacity(0.2))
            
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundStyle(LinearGradient(colors: [.Lavendar, .CustomPink, .SystemBeige], startPoint: .center, endPoint: .bottom))
                .rotationEffect(Angle(degrees: -90))
            
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(width: 58, height: 58)
        .animation(.easeOut(duration: 0.6), value: progress)
    }
}

struct Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            CircularProgressView(current: 1, total: 4)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
