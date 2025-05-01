//
//  AuthTextField.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import SwiftUI

struct AuthTextField: View {
    
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .cornerRadius(50)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .cornerRadius(50)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(50)
    }
}

