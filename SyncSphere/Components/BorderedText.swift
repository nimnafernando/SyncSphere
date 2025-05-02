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
    
    @State private var isEditing = false
    @State private var editedText: String = ""
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            if let frontImage = frontImage {
                Image(systemName: frontImage)
                    .font(.title2)
                    .foregroundColor(Color.gray)
            }
            
            VStack(alignment: .leading) {
                Text(placeholder)
                    .font(.title3)
                
                if isEditing {
                    TextField("", text: $editedText)
                        .cornerRadius(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.gray),
                            alignment: .bottom
                        )
                        .onAppear {
                            editedText = text
                        }
                        .onSubmit {
                            saveEdit()
                        }
                } else {
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let iconName = iconName {
                Button(action: {
                    if isEditing {
                        saveEdit()
                    } else {
                        isEditing = true
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark" : iconName)
                        .font(.title2)
                        .foregroundColor(color)
                        .padding(9)
                        .background(color?.opacity(0.3))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 14)
    }
    
    private func saveEdit() {
        profileViewModel.updateUsername(to: editedText)
        isEditing = false
    }
}


//#Preview {
//    BorderedText(text: "text", placeholder: "Name", iconName: "pencil", frontImage: "person" ,color: .blue, profileViewModel: ProfileViewModel)
//}
