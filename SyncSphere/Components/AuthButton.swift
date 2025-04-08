//
//  AuthButton.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import SwiftUI

struct AuthButton: View {
    
    var label: String
    var width: CGFloat?
    var icon: String?
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack{
                if let icon = icon {
                    Image(systemName: icon)
                        .padding()
                        .font(.title2)
                } else {
                    Image(systemName: "")
                }
                
                Text(label)
                    .font(.headline)
                
                    .frame(width:  UIScreen.main.bounds.width * (width ?? 0.5), height: UIScreen.main.bounds.width * 0.12)
                    
            }
        }.background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 0.5)
        )
    }
}

#Preview {
    AuthButton(label: "label", action: { })
}
