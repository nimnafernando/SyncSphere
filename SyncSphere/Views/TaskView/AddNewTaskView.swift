//
//  AddNewTaskView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct AddNewTaskView: View {
    let event: SyncEvent

    @State private var taskName: String = ""
    @State private var dueDate: Date = Date()
    @State private var category: String = ""
    @State private var selectedStatus: Int = 0 // 0: Not Started, 1: In Progress, 2: Completed
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success

    // Example categories, you can fetch from your backend if needed
    let categories = ["General", "Flowers", "Food", "Decor", "Other"]

    var body: some View {
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
                .padding(.horizontal)

                // Due Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Date")
                        .font(.headline)
                    DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // Category
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.headline)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(12)
                }
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

        // Create your EventTask model and save to Firestore or your backend
        let newTask = EventTask(
            id: UUID().uuidString,
            title: taskName,
            dueDate: dueDate.timeIntervalSince1970,
            category: category,
            isCompleted: selectedStatus == 2,
            status: selectedStatus
        )

        // TODO: Save newTask to backend, associated with event.eventId

        toastMessage = "Task added successfully!"
        toastType = .success
        showToast = true

        // Optionally, pop the view or reset fields after a delay
    }
}

// Example EventTask model for preview
struct EventTask: Identifiable {
    let id: String
    let title: String
    let dueDate: TimeInterval
    let category: String?
    let isCompleted: Bool
    let status: Int
}

#Preview {
    AddNewTaskView(event: SyncEvent(
        eventId: "evt001",
        eventName: "Birthday",
        dueDate: Date().timeIntervalSince1970,
        venue: "Colombo",
        priority: 1,
        isOutdoor: false,
        statusId: 1,
        createdAt: Date().timeIntervalSince1970
    ))
}
