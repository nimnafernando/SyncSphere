//
//  BorderedText.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

struct BorderedText: View {
    
    var text: String
    var placeholder: String
    var iconName: String?
    var frontImage: String?
    var color: Color?
    
    var body: some View {
        HStack(spacing: 12){
            Image(systemName: frontImage ?? "")
                .font(.title2)
                .foregroundColor(Color.gray)
            
            VStack(alignment: .leading){
                
                Text(placeholder)
                    .font(.title3)
                
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: iconName ?? "")
                .font(.title2)
                .foregroundColor(color)
                .padding(9)
                .background(color?.opacity(0.3))
                .clipShape(Circle())
        }
        .padding(.horizontal, 14)
    }
}

#Preview {
    BorderedText(text: "text", placeholder: "Name", iconName: "pencil", frontImage: "person" ,color: .blue)
}
