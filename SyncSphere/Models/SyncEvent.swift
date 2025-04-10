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
    
    // For Identifiable conformance
    var id: String {
        return eventId ?? UUID().uuidString
    }
    
    // Custom initializer for manual creation
    init(eventId: String, eventName: String, dueDate: TimeInterval, venue: String?, priority: Int?, isOutdoor: Bool, statusId: Int?, createdAt: TimeInterval?) {
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
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        eventId = try container.decodeIfPresent(String.self, forKey: .eventId)
        eventName = try container.decode(String.self, forKey: .eventName)
        
        // Handle different date formats
        if let dateDouble = try? container.decode(Double.self, forKey: .dueDate) {
            dueDate = dateDouble
        } else if let dateInt = try? container.decode(Int.self, forKey: .dueDate) {
            dueDate = TimeInterval(dateInt)
        } else if let dateString = try? container.decode(String.self, forKey: .dueDate),
                  let dateDouble = Double(dateString) {
            dueDate = dateDouble
        } else {
            throw DecodingError.dataCorruptedError(forKey: .dueDate, in: container, debugDescription: "Expected date format")
        }
        
        // Optional fields
        venue = try container.decodeIfPresent(String.self, forKey: .venue)
        priority = try container.decodeIfPresent(Int.self, forKey: .priority)
        isOutdoor = try container.decodeIfPresent(Bool.self, forKey: .isOutdoor)!
        statusId = try container.decodeIfPresent(Int.self, forKey: .statusId)
        
        // Handle different date formats for createdAt
        if let dateDouble = try? container.decodeIfPresent(Double.self, forKey: .createdAt) {
            createdAt = dateDouble
        } else if let dateInt = try? container.decodeIfPresent(Int.self, forKey: .createdAt) {
            createdAt = TimeInterval(dateInt)
        } else if let dateString = try? container.decodeIfPresent(String.self, forKey: .createdAt),
                  let dateDouble = Double(dateString) {
            createdAt = dateDouble
        } else {
            createdAt = nil
        }
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
