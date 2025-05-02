//
//  User.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import Foundation

struct SyncUser : Codable, Identifiable{
    
    let id: String
    var username: String
    let email: String
    let createdAt: TimeInterval
}
