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
    let eventId: String
    let isCompleted: Bool // set this by checking status value
    let status: Int
    
}
