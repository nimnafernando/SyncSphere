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
                    
                    // Date & Countdown Card
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            VStack(spacing: 12) {
                                Text(formatDate(event.dueDate))
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                CountDown(dueDate: Date(timeIntervalSince1970: event.dueDate))
                                    .padding(.top, 4)
                            }
                                .padding()
                        )
                        .frame(maxWidth: .infinity, minHeight: 120)
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
                        if taskViewModel.tasks.isEmpty {
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
                                ForEach(taskViewModel.tasks) { task in
                                    EventTaskCardView(
                                        task: task,
                                        onDelete: {
                                            //taskViewModel.deleteTask(task)
                                        },
                                        onComplete: {
                                            //                                            taskViewModel.completeTask(task)
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
            isLoading = true
            errorMessage = nil
            taskViewModel.fetchEventTasks(for: event) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let tasks):
                        taskViewModel.tasks = tasks
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
