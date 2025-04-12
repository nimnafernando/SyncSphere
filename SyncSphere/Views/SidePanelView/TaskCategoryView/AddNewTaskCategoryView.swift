//
//  AddNewTaskCategoryView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct AddNewTaskCategoryView: View {
    @StateObject private var viewModel = TaskCategoryViewModel()
    
    @State private var name: String = ""
    @State private var colorCode: String = ""
    @State private var createdBy: String = "userId_123" // Replace with dynamic user ID
    @State private var message: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add New Task Category")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextField("Category Name", text: $name)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            TextField("Hex Color (e.g. #FF5733)", text: $colorCode)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            Button(action: {
                guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                    message = "Category name is required."
                    return
                }
                
                viewModel.addTaskCategory(name: name, color: colorCode.isEmpty ? nil : colorCode, createdBy: createdBy)
                message = "Category added successfully."
                name = ""
                colorCode = ""
                
            }) {
                Text("Add Category")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.green)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
    }
}
