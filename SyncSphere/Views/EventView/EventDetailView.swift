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

    var body: some View {
        ZStack {
            GradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ... (Event title, countdown, progress bar, etc.)

                    Text("Tasks")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)

                    if taskViewModel.tasks.isEmpty {
                        VStack(spacing: 12) {
                            Text("No tasks available, but you can add tasks.")
                                .italic()
                                .foregroundColor(.gray)
                            Button(action: { showNewTask = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add New Task")
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color("Lavendar"))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(taskViewModel.tasks) { task in
                                EventTaskCardView(
                                    task: task,
                                    onDelete: { /*taskViewModel.deleteTask(task)*/
                                    },
                                    onComplete: { /*taskViewModel.completeTask(task)*/
                                    },
                                    onTap: {
                                        // onTap action
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 80)
            }

            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showNewTask = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color("Lavendar")))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewTask) {
            // Present your NewTaskView here
        }
        .onAppear {
            taskViewModel.fetchTasks(forEventId: event.eventId)
        }
    }
}

#Preview {
    let mockEvent = SyncEvent(
        eventId: "evt001",
        eventName: "Team Meeting",
        dueDate: Date().timeIntervalSince1970,
        venue: "Colombo",
        priority: 1,
        isOutdoor: false,
        statusId: 1,
        createdAt: Date().timeIntervalSince1970
    )
    return NavigationStack {
        EventDetailView(event: mockEvent)
    }
}
