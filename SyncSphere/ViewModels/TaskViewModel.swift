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
                completion(.failure(NSError(domain: "SyncEvent", code: 0, userInfo: [NSLocalizedDescriptionKey: "Event ID is missing."])))
                return
            }
            let db = Firestore.firestore()
            db.collection("events").document(eventId).collection("tasks").getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                let tasks: [SyncTask] = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let id = data["id"] as? String,
                        let title = data["title"] as? String,
                        let dueDate = data["dueDate"] as? TimeInterval,
                        let eventId = data["eventId"] as? String,
                        let isCompleted = data["isCompleted"] as? Bool,
                        let status = data["status"] as? Int
                    else {
                        return nil
                    }
                    let category = data["category"] as? String
                    return SyncTask(
                        id: id,
                        taskName: title,
                        dueDate: dueDate,
                        taskCategory: category,
                        eventId: eventId,
                        isCompleted: isCompleted,
                        status: status
                    )
                }
                completion(.success(tasks))
            }
        }
    
    func addEventTask(eventId: String, task: SyncTask, completion: @escaping (Result<Void, Error>) -> Void) {
        
//        let taskData: [String: Any] = [
//            "id": task.id,
//            "title": task.taskName,
//            "dueDate": task.dueDate,
//            "category": task.taskCategory ?? "",
//            "isCompleted": task.isCompleted,
//            "status": task.status
//        ]
        
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






