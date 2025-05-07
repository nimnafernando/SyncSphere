//
//  TaskViewModel.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine

class TaskViewModel: ObservableObject {
    
    
    @Published var tasks: [SyncTask] = []
    
    private let db = Firestore.firestore()
    private let collectionName = "tasks"
    
    // Fetch all tasks for a given eventId
    func fetchEventTasks(for event: SyncEvent, completion: @escaping (Result<[SyncTask], Error>) -> Void) {
        guard let eventId = event.eventId else {
            print("TaskViewModel: Event ID is missing")
            completion(.failure(NSError(domain: "SyncEvent", code: 0, userInfo: [NSLocalizedDescriptionKey: "Event ID is missing."])))
            return
        }
        
        print("TaskViewModel: Fetching tasks for event ID: \(eventId)")
        
        db.collection(collectionName)
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("TaskViewModel: Error fetching tasks: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("TaskViewModel: No tasks found for event ID: \(eventId)")
                    completion(.success([]))
                    return
                }
                
                print("TaskViewModel: Found \(documents.count) tasks")
                
                let tasks: [SyncTask] = documents.compactMap { doc in
                    let data = doc.data()
                    print("TaskViewModel: Processing task document: \(doc.documentID)")
                    print("TaskViewModel: Task data: \(data)")
                    
                    guard
                        let title = data["taskName"] as? String,
                        let dueDate = data["dueDate"] as? TimeInterval,
                        let eventId = data["eventId"] as? String,
                        let isCompleted = data["isCompleted"] as? Bool,
                        let status = data["status"] as? Int,
                        let taskCategoryId = data["taskCategoryId"] as? String
                    else {
                        print("TaskViewModel: Failed to parse task data for document: \(doc.documentID)")
                        return nil
                    }
                    
                    let task = SyncTask(
                        id: doc.documentID,
                        taskName: title,
                        dueDate: dueDate,
                        taskCategoryId: taskCategoryId,
                        eventId: eventId,
                        isCompleted: isCompleted,
                        status: status
                    )
                    print("TaskViewModel: Successfully created task: \(task.taskName)")
                    return task
                }
                
                print("TaskViewModel: Successfully processed \(tasks.count) tasks")
                completion(.success(tasks))
            }
        }

    func addEventTask(eventId: String, task: SyncTask, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection(collectionName).addDocument(from: task) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func completeTask(_ task: SyncTask, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let taskId = task.id else {
            completion(.failure(NSError(domain: "Task", code: 0, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing."])))
            return
        }
        
        let updatedTask = SyncTask(
            id: taskId,
            taskName: task.taskName,
            dueDate: task.dueDate,
            taskCategoryId: task.taskCategoryId,
            eventId: task.eventId,
            isCompleted: true,
            status: 2  // Set status to Completed
        )
        
        do {
            try db.collection(collectionName).document(taskId).setData(from: updatedTask) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Update local tasks array
                    if let index = self.tasks.firstIndex(where: { $0.id == taskId }) {
                        self.tasks[index] = updatedTask
                    }
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
        
    func deleteTask(_ task: SyncTask, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let taskId = task.id else {
            completion(.failure(NSError(domain: "Task", code: 0, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing."])))
            return
        }
        
        db.collection(collectionName).document(taskId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Remove from local tasks array
                self.tasks.removeAll { $0.id == taskId }
                completion(.success(()))
            }
        }
    }
   
    func updateTask(_ task: SyncTask) async throws {
        print("TaskViewModel: Starting to update task: \(task.taskName)")
        
        guard let taskId = task.id else {
            print("TaskViewModel: Task ID is missing")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing"])
        }
        
        print("TaskViewModel: Found task ID: \(taskId)")
        
        let taskData: [String: Any] = [
            "taskName": task.taskName,
            "dueDate": task.dueDate,
            "taskCategoryId": task.taskCategoryId,
            "eventId": task.eventId,
            "isCompleted": task.isCompleted,
            "status": task.status
        ]
        
        // Update Firestore document
        try await db.collection(collectionName).document(taskId).setData(taskData, merge: true)
                
        // Update local tasks array on the main thread
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            await MainActor.run {
                tasks[index] = task
            }
        }
        
        await MainActor.run {
            NotificationCenter.default.post(name: NSNotification.Name("TaskUpdated"), object: nil)
        }
    }
    
    func fetchTask(byId taskId: String) async throws -> SyncTask {
        print("TaskViewModel: Fetching task with ID: \(taskId)")
        
        let document = try await db.collection(collectionName).document(taskId).getDocument()
        guard let data = document.data() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
        }
        
        let task = SyncTask(
            id: taskId,
            taskName: data["taskName"] as? String ?? "",
            dueDate: data["dueDate"] as? TimeInterval ?? 0,
            taskCategoryId: data["taskCategoryId"] as? String ?? "",
            eventId: data["eventId"] as? String ?? "",
            isCompleted: data["isCompleted"] as? Bool ?? false,
            status: data["status"] as? Int ?? 0
        )
        
        return task
    }
    
    func getTaskCompletionStats(for eventId: String) async throws -> (total: Int, completed: Int) {
        print("TaskViewModel: Getting task completion stats for event: \(eventId)")
        
        let snapshot = try await db.collection(collectionName)
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments()
        
        let tasks = snapshot.documents.compactMap { doc -> SyncTask? in
            let data = doc.data()
            guard
                let title = data["taskName"] as? String,
                let dueDate = data["dueDate"] as? TimeInterval,
                let eventId = data["eventId"] as? String,
                let isCompleted = data["isCompleted"] as? Bool,
                let status = data["status"] as? Int,
                let taskCategoryId = data["taskCategoryId"] as? String
            else {
                return nil
            }
            
            return SyncTask(
                id: doc.documentID,
                taskName: title,
                dueDate: dueDate,
                taskCategoryId: taskCategoryId,
                eventId: eventId,
                isCompleted: isCompleted,
                status: status
            )
        }
        
        let totalTasks = tasks.count
        let completedTasks = tasks.filter { $0.isCompleted }.count
        
        print("TaskViewModel: Found \(totalTasks) total tasks, \(completedTasks) completed")
        return (totalTasks, completedTasks)
    }
}






