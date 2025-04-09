//
//  AuthTextField.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import SwiftUI

struct AuthTextField: View {
    
    var iconName: String
       var placeholder: String
       @Binding var text: String
       var isSecure: Bool = false

       var body: some View {
           HStack {
               Image(systemName: iconName)
                   .font(.title2)
                   .foregroundColor(.gray)

               if isSecure {
                   SecureField(placeholder, text: $text)
                       .autocapitalization(.none)
               } else {
                   TextField(placeholder, text: $text)
                       .autocapitalization(.none)
               }
           }
           .padding()
           .overlay(
               RoundedRectangle(cornerRadius: 8)
                   .stroke(Color.gray, lineWidth: 1)
           )
       }
}

