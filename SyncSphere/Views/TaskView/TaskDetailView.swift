//
//  TaskDetailView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct TaskDetailView: View {
    let task: SyncTask
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var categoryViewModel = TaskCategoryViewModel()
    @State private var currentTask: SyncTask
    @State private var showEditTask = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    
    init(task: SyncTask) {
        self.task = task
        _currentTask = State(initialValue: task)
    }
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title and Edit Button
                    HStack {
                        Text(currentTask.taskName)
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        NavigationLink(destination: EditTaskView(task: currentTask)) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title)
                                .foregroundColor(Color("Lavendar"))
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    
                    // Due Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.headline)
                        Text(formatDate(currentTask.dueDate))
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.OffWhite)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Task Category Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Category")
                            .font(.headline)
                        HStack {
                            Circle()
                                .fill(Color(hex: categoryViewModel.categories.first(where: { $0.id == currentTask.taskCategoryId })?.color ?? "#3498DB"))
                                .frame(width: 12, height: 12)
                            Text(categoryViewModel.categories.first(where: { $0.id == currentTask.taskCategoryId })?.name ?? "Uncategorized")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.OffWhite)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.headline)
                        HStack(spacing: 15) {
                            ForEach(statusPills, id: \.value) { pill in
                                Text(pill.title)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 14)
                                    .background(currentTask.status == pill.value ? pill.color : Color.OffWhite)
                                    .foregroundColor(currentTask.status == pill.value ? .white : pill.color)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(pill.color, lineWidth: 1)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.OffWhite)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
            }
            .onAppear {
                refreshTaskData()
                categoryViewModel.fetchAllTaskCategories()
            }
            
            if showToast {
                VStack {
                    ToastView(message: toastMessage, type: toastType)
                        .padding(.top, 20)
                    Spacer()
                }
                .zIndex(1)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func refreshTaskData() {
        guard let taskId = currentTask.id else { return }
        
        Task {
            do {
                let updatedTask = try await taskViewModel.fetchTask(byId: taskId)
                await MainActor.run {
                    currentTask = updatedTask
                }
            } catch {
                print("Error refreshing task data: \(error)")
                // Optionally show an error toast
                await MainActor.run {
                    toastMessage = "Failed to refresh task data"
                    toastType = .error
                    showToast = true
                }
            }
        }
    }
    
    private var statusPills: [(title: String, value: Int, color: Color)] {
        [
            ("Not Started", 0, .red),
            ("In Progress", 1, .blue),
            ("Completed", 2, .green)
        ]
    }
    
    private func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

#Preview {
    TaskDetailView(task: SyncTask(
        id: "1",
        taskName: "Sample Task",
        dueDate: Date().timeIntervalSince1970,
        taskCategoryId: "1",
        eventId: "1",
        isCompleted: false,
        status: 0
    ))
}

