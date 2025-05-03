//
//  SyncTask.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import Foundation
import FirebaseFirestore

struct SyncTask: Codable, Identifiable, Hashable {
    
    @DocumentID var id: String?
    let taskName: String
    let dueDate: TimeInterval
    let taskCategory: String?
    let taskNotes: String
    let priorityId: Int
    let eventId: String
    let isCompleted: Bool
    let status: Int
    
}
