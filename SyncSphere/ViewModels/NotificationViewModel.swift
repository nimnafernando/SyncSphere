//
//  NotificationViewModel.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-07.
//

import Foundation
import Combine

struct NotificationItem: Identifiable {
    let id = UUID()
    let taskName: String
    let dueDate: Date
    let eventName: String
}

class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let eventViewModel = EventViewModel()
    private let taskViewModel = TaskViewModel()
    private var cancellables = Set<AnyCancellable>()

    func fetchNotifications(for userId: String) {
        isLoading = true
        notifications = []
        errorMessage = nil
        
        eventViewModel.getEventsForUser(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    if events.isEmpty {
                        self?.isLoading = false
                        return
                    }
                    self?.fetchTasks(for: events)
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchTasks(for events: [SyncEvent]) {
        let group = DispatchGroup()
        var notificationItems: [NotificationItem] = []
        let now = Date()
        let next24h = now.addingTimeInterval(24 * 60 * 60)
        
        for event in events {
            group.enter()
            taskViewModel.fetchEventTasks(for: event) { result in
                switch result {
                case .success(let tasks):
                    for task in tasks {
                        let dueDate = Date(timeIntervalSince1970: task.dueDate)
                        if !task.isCompleted && dueDate > now && dueDate <= next24h {
                            notificationItems.append(NotificationItem(
                                taskName: task.taskName,
                                dueDate: dueDate,
                                eventName: event.eventName
                            ))
                        }
                    }
                case .failure(_):
                    break
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.notifications = notificationItems.sorted { $0.dueDate < $1.dueDate }
            self.isLoading = false
        }
    }
} 
