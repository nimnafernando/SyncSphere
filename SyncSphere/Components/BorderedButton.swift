//
//  BorderedButton.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-20.
//

import SwiftUI

struct BorderedButton: View {
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
                    .foregroundColor(Color.Lavendar)
                    .bold()
                    .frame(width:  UIScreen.main.bounds.width * (width ?? 0.9), height: UIScreen.main.bounds.width * 0.14)
                
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 50)
                .stroke(Color.Lavendar, lineWidth: 0.5)
        )
    }
}

#Preview {
    BorderedButton(label: "label", action: { })
}
