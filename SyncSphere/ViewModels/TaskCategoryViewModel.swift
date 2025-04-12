//
//  TaskCategoryViewModel.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

class TaskCategoryViewModel: ObservableObject {
    @Published var categories: [SyncTaskCategory] = []
    
    private let db = Firestore.firestore()
    private let collectionName = "taskCategory"
    
    
    
    func fetchAllTaskCategories() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User id is not available to fetch user task category details")
            return }
        
        db.collection(collectionName)
            .whereField("createdBy", isEqualTo: userId)
            .getDocuments {
                snapshot, error in
                if let error = error {
                    print("Error fetching task categories : \(error)")
                    return
                }
                
                guard let documenta = snapshot?.documents else {
                    print("No task categories found.")
                    return
                }
                
                do {
                    self.categories = try documenta.map {
                        try $0.data(as: SyncTaskCategory.self)
                    }
                } catch {
                    print("Error decoding task categories : \(error)")
                }
            }
    }
    
    func addTaskCategory(name: String, color: String? = nil, createdBy: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User id is not available to fetch user task category details")
            return }
        
        
        let newTaskCategory = SyncTaskCategory(name: name,
                                           color: color,
                                               createdBy: userId)
        
        
        
        do {
            _ = try db.collection(collectionName).addDocument(from: newTaskCategory) {
                error in
                if let error = error {
                    print("Error occurred while adding category: \(error.localizedDescription)")
                } else {
                    print("Category added successfully.")
                }
            }
        } catch {
            print("Failed to encode and add category: \(error)")
        }
        
        
    }

    
}
