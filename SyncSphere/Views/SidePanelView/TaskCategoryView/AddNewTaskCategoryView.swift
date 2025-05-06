//
//  AddNewTaskCategoryView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct AddNewTaskCategoryView: View {
    @StateObject private var viewModel = TaskCategoryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var colorCode: String = ""
    @State private var createdBy: String = "userId_123" // Replace with dynamic user ID
    @State private var message: String = ""
    @State private var showMessage: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Add New Task Category")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Category Name")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter category name", text: $name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Color (Optional)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Hex Color (e.g. #FF5733)", text: $colorCode)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            
            if showMessage {
                Text(message)
                    .foregroundColor(message.contains("successfully") ? .green : .red)
                    .font(.subheadline)
                    .padding(.vertical, 8)
            }
            
            Spacer()
            
            Button(action: {
                guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                    message = "Category name is required."
                    showMessage = true
                    return
                }
                
                viewModel.addTaskCategory(name: name, color: colorCode.isEmpty ? nil : colorCode, createdBy: createdBy)
                message = "Category added successfully."
                showMessage = true
                
                // Clear fields and dismiss after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    name = ""
                    colorCode = ""
                    dismiss()
                }
            }) {
                Text("Add Category")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.Lavendar)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AddNewTaskCategoryView()
    }
}

