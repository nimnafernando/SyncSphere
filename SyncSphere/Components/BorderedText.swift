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
    
       var body: some View {
           HStack {
               Image(systemName: iconName ?? "")
                   .font(.title2)
                   .foregroundColor(.gray)
               
               Text(placeholder)
                   .padding(.trailing, 10)
               
               Text(text)
                   .padding(10)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .overlay(
                       RoundedRectangle(cornerRadius: 8)
                           .stroke(Color.gray, lineWidth: 1)
                   )
           }
           .padding()
           .frame(maxWidth: .infinity, alignment: .leading)
        
       }
}

#Preview {
    BorderedText(text: "text", placeholder: "Name", iconName: "person")
}
