//
//  SyncEvent.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//


import Foundation
import FirebaseFirestore

struct SyncEvent: Codable, Identifiable {
    var eventId: String?
    let eventName: String
    let dueDate: TimeInterval
    let venue: String?
    let priority: Int?
    let isOutdoor: Bool
    let statusId: Int?
    let createdAt: TimeInterval?
    var calendarEventId: String? 
    // For Identifiable conformance
    var id: String {
            return eventId ?? UUID().uuidString
        }
    
    // Custom initializer for manual creation
    init(eventId: String?, eventName: String, dueDate: TimeInterval, venue: String?, priority: Int?, isOutdoor: Bool, statusId: Int?, createdAt: TimeInterval?) {
        self.eventId = eventId
        self.eventName = eventName
        self.dueDate = dueDate
        self.venue = venue
        self.priority = priority
        self.isOutdoor = isOutdoor
        self.statusId = statusId
        self.createdAt = createdAt
    }
    
    // Keep the Codable initializer for completeness
    enum CodingKeys: String, CodingKey {
        case eventId
        case eventName
        case dueDate
        case venue
        case priority
        case isOutdoor
        case statusId
        case createdAt
    }
    
}

struct EventStatus: Codable, Identifiable {
    @DocumentID var id: String?
    let status: String
}

struct UserEvent: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let eventId: String
}
