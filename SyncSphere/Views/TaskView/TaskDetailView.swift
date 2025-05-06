//
//  TaskDetailView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct TaskDetailView: View {
    let task: SyncTask
    @StateObject private var categoryViewModel = TaskCategoryViewModel()
    @State private var categoryName: String = ""
    @State private var categoryColor: String = "#3498DB"
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Task Name
                    Text(task.taskName)
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 8)
                        .padding(.horizontal)
                    
                    // Due Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.headline)
                        Text(formatDate(task.dueDate))
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Category Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.headline)
                        if !categoryName.isEmpty {
                            Text(categoryName)
                                .font(.title2)
                                .foregroundColor(Color(hex: categoryColor))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.headline)
                        Text(statusText)
                            .font(.title2)
                            .foregroundColor(statusColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                .padding(.top, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCategoryDetails()
        }
    }
    
    private var statusText: String {
        switch task.status {
        case 0: return "Not Started"
        case 1: return "In Progress"
        case 2: return "Completed"
        default: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch task.status {
        case 0: return .red
        case 1: return .orange
        case 2: return .green
        default: return .gray
        }
    }
    
    private func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func loadCategoryDetails() {
        categoryViewModel.fetchAllTaskCategories()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let category = categoryViewModel.categories.first(where: { $0.id == task.taskCategoryId }) {
                categoryName = category.name
                categoryColor = category.color ?? "#3498DB"
            }
        }
    }
}
