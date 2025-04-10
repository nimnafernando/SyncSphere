//
//  Category.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import Foundation
import FirebaseFirestore

struct SyncCategory: Codable, Identifiable {
    @DocumentID var id: String?
    let category: String
    let color: String
}

struct TaskCategory: Codable, Identifiable {
    @DocumentID var id: String?
    let categoryId: String
    let taskId: String
}
