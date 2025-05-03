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

       func fetchTasks(forEventId eventId: String?) {
           guard let eventId = eventId else { return }
           // Fetch tasks from Firestore or your backend where eventId == eventId
           // Update self.tasks
       }
    
}






