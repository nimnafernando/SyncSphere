//
//  AddNewTaskView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct AddNewTaskView: View {
    let event: SyncEvent
    
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var categoryViewModel = TaskCategoryViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var taskName: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedCategoryId: String = ""
    @State private var selectedStatus: Int = 0 // 0: Not Started, 1: In Progress, 2: Completed
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    @State private var showAllCategories = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: 24) {
                    Text("Add New Task")
                        .font(.title)
                        .bold()
                        .padding(.top, 8)

                    // Task Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Name")
                            .font(.headline)
                        TextField("Enter task name", text: $taskName)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Due Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.headline)
                        HStack {
                            DatePicker(
                                "",
                                selection: $dueDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Category Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Task Category")
                                .font(.headline)
                            Spacer()
                            Button(action: { showAllCategories = true }) {
                                Text("View Task Category")
                                    .font(.footnote)
                                    .foregroundColor(Color("Lavendar"))
                            }
                            // Hidden NavigationLink for programmatic navigation
                            NavigationLink(
                                destination: AllTaskCategoryView(),
                                isActive: $showAllCategories
                            ) { EmptyView() }
                            .hidden()
                        }
                        Picker("Select a task category", selection: $selectedCategoryId) {
                           Text("Select a task category").tag("")
                           ForEach(categoryViewModel.categories) { category in
                               Text(category.name).tag(category.id ?? "")
                           }
                       }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.headline)
                        HStack(spacing: 12) {
                            ForEach(statusPills, id: \.value) { pill in
                                Button(action: { selectedStatus = pill.value }) {
                                    Text(pill.title)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 14)
                                        .background(selectedStatus == pill.value ? pill.color : Color.white.opacity(0.9))
                                        .foregroundColor(selectedStatus == pill.value ? .white : pill.color)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 40)
                                                .stroke(pill.color, lineWidth: 1)
                                        )
                                        .cornerRadius(40)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    Spacer()

                    // Save Button
                    Button(action: saveTask) {
                        Text("Save Task")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Lavendar"))
                            .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.top, 16)
                .onAppear {
                    categoryViewModel.fetchAllTaskCategories()
                }
                .disabled(isLoading)
                   if isLoading {
                       ProgressView()
                           .scaleEffect(1.5)
                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                           .background(Color.black.opacity(0.2))
                   }

                // Toast (if you have a ToastView)
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
    }

    private var statusPills: [(title: String, value: Int, color: Color)] {
        [
            ("Not Started", 0, .red),
            ("In Progress", 1, .blue),
            ("Completed", 2, .green)
        ]
    }

    private func saveTask() {
        // Validate
        guard !taskName.trimmingCharacters(in: .whitespaces).isEmpty else {
            toastMessage = "Task name is required"
            toastType = .error
            showToast = true
            return
        }
        guard !selectedCategoryId.isEmpty else {
           toastMessage = "Please select a task category"
           toastType = .error
           showToast = true
           return
       }
        
        isLoading = true
        
        // Create your EventTask model and save to Firestore or your backend
        let newTask = SyncTask(
                    id: UUID().uuidString,
                    taskName: taskName,
                    dueDate: dueDate.timeIntervalSince1970,
                    taskCategoryId: selectedCategoryId,
                    eventId: event.eventId ?? "",
                    isCompleted: selectedStatus == 2,
                    status: selectedStatus
                )
        
        
        taskViewModel.addEventTask(eventId: event.eventId ?? "", task: newTask) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    toastMessage = "Task added successfully!"
                    toastType = .success
                    showToast = true
                                        
                    // Dismiss the view after a short delay to show the success message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                case .failure(let error):
                    toastMessage = "Failed to add task: \(error.localizedDescription)"
                    toastType = .error
                    showToast = true
                }
                showToast = true
            }
        }
    }
}
