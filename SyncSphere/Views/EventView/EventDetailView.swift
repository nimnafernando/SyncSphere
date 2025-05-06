//
//  EventDetailView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-03.
//

import SwiftUI
import SwiftUI

struct EventDetailView: View {
    let event: SyncEvent
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var showNewTask = false
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var tasks: [SyncTask] = [] // Add state for tasks
    
    private var priorityPills: [(title: String, value: Int, color: Color)] {
        [
            ("High", 1, .red),
            ("Medium", 2, .blue),
            ("Low", 3, .green),
            ("default", 4, Color("Lavendar"))
        ]
    }
    
    private func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    
    var body: some View {
        ZStack {
            GradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ... (Event title, countdown, progress bar, etc.)
                    HStack {
                        Text(event.eventName)
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        NavigationLink(destination: NewEventView(existingEvent: event)) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color("Lavendar"))
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)

                    // Countdown Section
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            VStack {
                                CountDown(dueDate: Date(timeIntervalSince1970: event.dueDate))
                            }
                            .padding(.vertical, 24) // Equal top and bottom padding
                            .padding(.horizontal)
                        )
                        .frame(maxWidth: .infinity, minHeight: 140)
                        .padding(.horizontal)
                    
                    // Due Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Date")
                            .font(.headline)
                        Text(formatDate(event.dueDate))
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 8) {
                        //                        Text("\(viewModel.completedTasksCount)/\(viewModel.tasks.count) Tasks Completed")
                        //                            .font(.subheadline)
                        //                            .bold()
                        //                        CustomProgressBar(progress: viewModel.progress)
                        //                            .frame(height: 16)
                        CustomProgressBar()
                            .padding(.top, 6)
                    }
                    .padding(.horizontal)
                    
                    // Venue Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Venue")
                            .font(.headline)
                        HStack {
                            let venue = event.venue ?? ""
                            Text(venue.isEmpty ? "No venue specified" : venue)
                                .foregroundColor(.primary)
                            if event.isOutdoor {
                                Text("Outdoor")
                                    .font(.caption)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    
                    // Priority Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Priority")
                            .font(.headline)
                        HStack(spacing: 12) {
                            ForEach(priorityPills, id: \.value) { pill in
                                Text(pill.title)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 14)
                                    .background(event.priority == pill.value ? pill.color : Color.white.opacity(0.9))
                                    .foregroundColor(event.priority == pill.value ? .white : pill.color)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 40)
                                            .stroke(pill.color, lineWidth: 1)
                                    )
                                    .cornerRadius(40)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    Section(
                        header:
                            HStack {
                                Text("Tasks")
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                NavigationLink(destination: AddNewTaskView(event: event)) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Task")
                                    }
                                    .font(.body)
                                    .foregroundColor(Color("Lavendar"))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)
                    ) {
                        if  tasks.isEmpty {
                            VStack {
                                Text("No tasks available, but you can add tasks.")
                                    .italic()
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(tasks) { task in
                                    EventTaskCardView(
                                        task: task,
                                        onDelete: {
                                            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                                tasks.remove(at: index)
                                            }
                                        },
                                        onComplete: {
                                            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                                let updatedTask = SyncTask(
                                                    id: task.id,
                                                    taskName: task.taskName,
                                                    dueDate: task.dueDate,
                                                    taskCategoryId: task.taskCategoryId,
                                                    eventId: task.eventId,
                                                    isCompleted: true,
                                                    status: 2
                                                )
                                                tasks[index] = updatedTask
                                            }
                                        },
                                        onTap: {
                                            // Handle tap (e.g., show task detail)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .onAppear {
                    loadTasks()
                }
            }
        }
    }
    
    private func loadTasks() {
        print("EventDetailView: Starting to load tasks")
        
        guard let eventId = event.eventId else {
            print("EventDetailView: Event ID is missing")
            errorMessage = "Event ID is missing"
            return
        }
        
        print("EventDetailView: Found event ID: \(eventId)")
        
        isLoading = true
        errorMessage = nil
        
        taskViewModel.fetchEventTasks(for: event) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedTasks):
                    print("EventDetailView: Successfully loaded \(fetchedTasks.count) tasks")
                    self.tasks = fetchedTasks // Update the local state
                case .failure(let error):
                    print("EventDetailView: Failed to load tasks: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
