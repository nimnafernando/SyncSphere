//
//  EventTaskCardView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-03.
//

import SwiftUI

struct EventTaskCardView: View {
    let task: SyncTask
    var onDelete: (() -> Void)?
    var onComplete: (() -> Void)?
    var onTap: (() -> Void)?
    
    @StateObject private var categoryViewModel = TaskCategoryViewModel()
    @State private var categoryName: String = ""
    @State private var categoryColor: String = "#3498DB" // Default color

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(task.isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                        .font(.system(size: 24))
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(task.taskName)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(formatDate(task.dueDate))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                HStack(spacing: 8) {
                    if !categoryName.isEmpty {
                        Text(categoryName)
                            .font(.caption)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(Color(hex: categoryColor).opacity(0.2))
                            .foregroundColor(Color(hex: categoryColor))
                            .cornerRadius(12)
                    }
                    Text(statusText)
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(12)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                onComplete?()
            } label: {
                Label("Complete", systemImage: "checkmark")
            }
            .tint(.green)
        }
        .onTapGesture {
            onTap?()
        }
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
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func loadCategoryDetails() {
       // First fetch all categories
       categoryViewModel.fetchAllTaskCategories()
       
       // Then find the matching category
       if let category = categoryViewModel.categories.first(where: { $0.id == task.taskCategoryId }) {
           categoryName = category.name
           categoryColor = category.color ?? "#3498DB"
       }
   }
}

