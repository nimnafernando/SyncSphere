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
}






