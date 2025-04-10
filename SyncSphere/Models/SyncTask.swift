//
//  SyncTask.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import Foundation
import FirebaseFirestore

struct Task: Codable, Identifiable {
    
    @DocumentID var id: String?
    let taskName: String
    let dueDate: Date
    let taskType: String
    let taskNotes: String
    let isDeleted: Bool
    let taskColor: String
    let priorityId: Int
    let eventId: String
    
}
