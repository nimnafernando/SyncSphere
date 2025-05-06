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
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var categoryName: String = ""
    @State private var categoryColor: String = "#3498DB" // Default color
    @State private var showTaskDetail = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    @State private var offset: CGFloat = 0
    @State private var isTaskCompleted: Bool = false

    var body: some View {
        ZStack {
            ZStack {
                // Complete action (right side - appears when swiping left)
                Rectangle()
                    .foregroundColor(.green)
                    .cornerRadius(20)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .overlay(
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 20)
                    )
                    .frame(height: UIScreen.main.bounds.height * 0.1)
                    .padding(.bottom, 10)
                    .opacity(offset < 0 ? 1 : 0)
                
                // Delete action (left side - appears when swiping right)
                Rectangle()
                    .foregroundColor(.red)
                    .cornerRadius(20)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .overlay(
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.leading, 20)
                    )
                    .frame(height: UIScreen.main.bounds.height * 0.1)
                    .padding(.bottom, 10)
                    .opacity(offset > 0 ? 1 : 0)
                
                // Card content
                Rectangle()
                    .fill(Color(hex: categoryColor).opacity(0.15))
                    .cornerRadius(20)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1)
                    .overlay(
                        HStack(alignment: .center, spacing: 16) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isTaskCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: isTaskCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isTaskCompleted ? .green : .gray)
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
                        .padding(20)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                self.offset = gesture.translation.width / 2.2
                            }
                            .onEnded { gesture in
                                let threshold: CGFloat = 80
                                
                                if offset < -threshold && !task.isCompleted {
                                    // Swiped left (showing right side) - mark as completed
                                    withAnimation {
                                        self.offset = -UIScreen.main.bounds.width * 0.1
                                    }
                                    
                                    // Small delay before triggering action and resetting
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        completeTask()
                                        
                                        // Reset after a slight delay
                                        withAnimation {
                                            self.offset = 0
                                        }
                                    }
                                } else if offset > threshold {
                                    // Swiped right (showing left side) - delete
                                    withAnimation {
                                        self.offset = UIScreen.main.bounds.width * 0.1
                                    }
                                    
                                    // Small delay before triggering action and resetting
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        deleteTask()
                                        
                                        // Reset after a slight delay
                                        withAnimation {
                                            self.offset = 0
                                        }
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        self.offset = 0
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        showTaskDetail = true
                    }
                    .padding(.bottom, 10)
            }
        }
        .navigationDestination(isPresented: $showTaskDetail) {
            TaskDetailView(task: task)
        }
        .onAppear {
            isTaskCompleted = task.isCompleted
            loadCategoryDetails()
        }
        .overlay(
            Group {
                if showToast {
                    ToastView(message: toastMessage, type: toastType)
                        .padding(.top, 20)
                }
            }
        )
    }

    private func showToastMessage(_ message: String, type: ToastType) {
        toastMessage = message
        toastType = type
        showToast = true
        
        // Hide toast after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showToast = false
            }
        }
    }

    private func completeTask() {
        // Update UI immediately
        withAnimation {
            isTaskCompleted = true
        }
        
        taskViewModel.completeTask(task) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    showToastMessage("Task marked as completed", type: .success)
                    onComplete?()
                case .failure(let error):
                    // Revert UI if the operation failed
                    withAnimation {
                        isTaskCompleted = false
                    }
                    showToastMessage("Failed to complete task: \(error.localizedDescription)", type: .error)
                }
            }
        }
    }
    
    private func deleteTask() {
        taskViewModel.deleteTask(task) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    showToastMessage("Task deleted successfully", type: .success)
                    // Add a small delay before removing the task to show the toast
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onDelete?()
                    }
                case .failure(let error):
                    showToastMessage("Failed to delete task: \(error.localizedDescription)", type: .error)
                }
            }
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
        case 1: return .blue
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
        print("EventTaskCardView: Starting to load category details for task: \(task.taskName)")
        print("EventTaskCardView: Task category ID: \(task.taskCategoryId)")
        
        // First fetch all categories
        categoryViewModel.fetchAllTaskCategories()
        
        // Add a small delay to ensure categories are fetched
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("EventTaskCardView: Available categories: \(self.categoryViewModel.categories.count)")
            print("EventTaskCardView: Categories: \(self.categoryViewModel.categories.map { "\($0.name) (ID: \($0.id ?? "nil"))" })")
            
            // Then find the matching category
            if let category = self.categoryViewModel.categories.first(where: { $0.id == self.task.taskCategoryId }) {
                print("EventTaskCardView: Found matching category: \(category.name)")
                self.categoryName = category.name
                self.categoryColor = category.color ?? "#3498DB"
            } else {
                print("EventTaskCardView: No matching category found for ID: \(self.task.taskCategoryId)")
                // Set default values if category not found
                self.categoryName = "Uncategorized"
                self.categoryColor = "#3498DB"
            }
        }
    }
}


