//
//  SyncTaskCategory.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import Foundation
import FirebaseFirestore

struct SyncTaskCategory: Identifiable, Codable {
    
    @DocumentID var id: String?
    var name: String
    var color: String? // Hex color, optional
    var createdBy: String
}
                            
                            
