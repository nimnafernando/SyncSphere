//
//  TaskCategoryDetailView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//


import SwiftUI

struct TaskCategoryDetailView: View {
    let category: SyncTaskCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Circle()
                    .fill(Color(hex: category.color ?? "#3498DB"))
                    .frame(width: 12, height: 12)
                
                Text(category.name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Category Details")
                    .font(.headline)
                
                HStack {
                    Text("Created By:")
                        .foregroundColor(.gray)
                    Text(category.createdBy)
                }
                
                if let color = category.color {
                    HStack {
                        Text("Color:")
                            .foregroundColor(.gray)
                        Text(color)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TaskCategoryDetailView(category: SyncTaskCategory(name: "Sample Category", color: "#3498DB", createdBy: "user123"))
}
