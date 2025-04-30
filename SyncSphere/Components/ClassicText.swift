//
//  ClassicText.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-20.
//

import SwiftUI

struct ClassicText: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        VStack{
            HStack {
                TextField(placeholder, text: $text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(.gray),
                alignment: .bottom
            )
        }.padding()
    }
}


