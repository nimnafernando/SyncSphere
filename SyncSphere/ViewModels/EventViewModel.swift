//
//  EventViewModel.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class EventViewModel: ObservableObject {
    
    private let db = Firestore.firestore()
    @Published var eventsByStatus: [Int: [SyncEvent]] = [:]
    @Published var eventCountsByStatus: [Int: Int] = [:]
    
    func getEventsForUser(userId: String, completion: @escaping (Result<[SyncEvent], Error>) -> Void) {
        print("Starting to fetch events for userId: \(userId)")
        
        let userRef = db.collection("user").document(userId)
        let userEventsRef = db.collection("userEvents")
        
        userEventsRef
            .whereField("userId", isEqualTo: userRef)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error fetching userEvents: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No documents found in userEvents collection for user \(userId)")
                    completion(.success([]))
                    return
                }
                
                let eventRefs: [DocumentReference] = documents.compactMap { doc in
                    guard let ref = doc.data()["eventId"] as? DocumentReference else {
                        print("Missing or invalid 'eventId' reference in doc \(doc.documentID)")
                        return nil
                    }
                    return ref
                }
                
                guard !eventRefs.isEmpty else {
                    print("No valid event references found.")
                    completion(.success([]))
                    return
                }
                
                let group = DispatchGroup()
                var events: [SyncEvent] = []
                var errors: [Error] = []
                
                for eventRef in eventRefs {
                    group.enter()
                    
                    eventRef.getDocument { [self] snapshot, error in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("Error fetching event \(eventRef.documentID): \(error)")
                            errors.append(error)
                            return
                        }
                        
                        guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                            print("No data found for event \(eventRef.documentID)")
                            return
                        }
                        
                        do {
                            let statusId = extractStatusId(from: data["statusId"])
                            let dueDate = extractTimestamp(from: data["dueDate"]) ?? 0
                            let createdAt = extractTimestamp(from: data["createdAt"])
                            let isOutdoor = extractBool(from: data["isOutdoor"]) ?? false
                            
                            let event = SyncEvent(
                                eventId: eventRef.documentID,
                                eventName: data["eventName"] as? String ?? "Unknown Event",
                                dueDate: dueDate,
                                venue: data["venue"] as? String,
                                priority: data["priority"] as? Int,
                                isOutdoor: isOutdoor,
                                statusId: statusId,
                                createdAt: createdAt
                            )
                            
                            print("Created event: \(event.eventName)")
                            events.append(event)
                            
                        }
                    }
                }
                //                self.updateExpiredEventStatuses(for: userId)
                group.notify(queue: .main) {
                    if !errors.isEmpty {
                        print("Completed with \(errors.count) error(s)")
                    } else {
                        print("Successfully fetched \(events.count) event(s)")
                    }
                    
                    let sortedEvents = events.sorted { $0.dueDate < $1.dueDate }
                    completion(.success(sortedEvents))
                }
            }
    }
    
    
    private func extractStatusId(from value: Any?) -> Int? {
        if let ref = value as? DocumentReference {
            let id = Int(ref.documentID) ?? Int(ref.path.components(separatedBy: "/").last ?? "")
            return id
        } else if let id = value as? Int {
            return id
        }
        return nil
    }
    
    private func extractTimestamp(from value: Any?) -> TimeInterval? {
        if let timestamp = value as? Timestamp {
            return TimeInterval(timestamp.seconds)
        } else if let double = value as? Double {
            return double
        } else if let int = value as? Int {
            return TimeInterval(int)
        }
        return nil
    }
    
    private func extractBool(from value: Any?) -> Bool? {
        if let bool = value as? Bool {
            return bool
        } else if let int = value as? Int {
            return int != 0
        }
        return nil
    }
    
    func getEventsWithStatus(userId: String, statusId: Int, completion: @escaping (Result<[SyncEvent], Error>) -> Void) {
        getEventsForUser(userId: userId) { result in
            switch result {
            case .success(let allEvents):
                // Filter events by the specified status ID
                let filteredEvents = allEvents.filter { $0.statusId == statusId }
                print("Filtered \(allEvents.count) events to \(filteredEvents.count) with status ID \(statusId)")
                completion(.success(filteredEvents))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getHighestPriorityEvent(userId: String, completion: @escaping (Result<SyncEvent?, Error>) -> Void) {
        getEventsForUser(userId: userId) { result in
            switch result {
            case .success(let events):
                let currentTime = Date().timeIntervalSince1970
                
                // Filter out due dates in the past
                let upcomingEvents = events.filter { $0.dueDate > currentTime }
                
                if upcomingEvents.isEmpty {
                    completion(.success(nil))
                    return
                }
                
                let sortedEvents = upcomingEvents.sorted { (event1, event2) -> Bool in
                    //compare by due date
                    if event1.dueDate != event2.dueDate {
                        return event1.dueDate < event2.dueDate
                    }
                    
                    //compare by priority (highest first)
                    if event1.priority != event2.priority {
                        return event1.priority ?? 3 > event2.priority ?? 3
                    }
                    
                    //compare by creation date (oldest first)
                    let created1 = event1.createdAt ?? 0
                    let created2 = event2.createdAt ?? 0
                    return created1 < created2
                }
                
                if let highestPriorityEvent = sortedEvents.first {
                    completion(.success(highestPriorityEvent))
                } else {
                    completion(.success(nil))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateExpiredEventStatuses(for userId: String) {
        getEventsForUser(userId: userId) { result in
            switch result {
            case .success(let events):
                let now = Date().timeIntervalSince1970
                let db = Firestore.firestore()
                
                for event in events {
                    if event.dueDate < now && event.statusId != 2 {
                        // Assume 2 = expired status
                        if let eventId = event.eventId {
                            db.collection("event").document(eventId).updateData([
                                "statusId": 2
                            ]) { error in
                                if let error = error {
                                    print("Failed to update event \(eventId): \(error)")
                                } else {
                                    print("Updated expired event: \(event.eventName)")
                                }
                            }
                        }
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch events: \(error)")
            }
        }
    }
    
    func addEventToFirestore(_ event: SyncEvent, completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()
        
        do {
            let documentRef: DocumentReference
            let isUpdate = event.eventId != nil && !event.eventId!.isEmpty
            
            if isUpdate {
                documentRef = db.collection("event").document(event.eventId!)
            } else {
                documentRef = db.collection("event").document()
                
                var newEvent = event
                newEvent.eventId = documentRef.documentID
                
                try documentRef.setData(from: newEvent) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        print("Event added with ID: \(documentRef.documentID)")
                        completion(.success(documentRef.documentID))
                    }
                }
                return
            }
            
            try documentRef.setData(from: event) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print(isUpdate ? "Event updated with ID: \(documentRef.documentID)" : "Event added with ID: \(documentRef.documentID)")
                    completion(.success(documentRef.documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func addUserEventRecord(userId: String, eventId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userEventRef = db.collection("userEvents").document()
        
        let userRef = db.document("/user/\(userId)")
        let eventRef = db.document("/event/\(eventId)")
        
        let data: [String: Any] = [
            "userId": userRef,
            "eventId": eventRef,  
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        userEventRef.setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateEventField(eventId: String, fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let documentRef = db.collection("event").document(eventId)
        
        documentRef.updateData(fields) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteEvent(eventId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let eventRef = db.collection("event").document(eventId)
        let userEventsRef = db.collection("userEvents")
        
        eventRef.delete { error in
            if let error = error {
                print("Error deleting event: \(error)")
                completion(.failure(error))
                return
            }
            
            userEventsRef.whereField("eventId", isEqualTo: eventId).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching related userEvents: \(error)")
                    completion(.failure(error))
                    return
                }
                
                let documents = snapshot?.documents ?? []
                if documents.isEmpty {
                    completion(.success(()))
                    return
                }
                
                var deleteCount = 0
                var failed = false
                
                for doc in documents {
                    doc.reference.delete { error in
                        if let error = error {
                            if !failed {
                                failed = true
                                completion(.failure(error))
                            }
                            return
                        }
                        
                        deleteCount += 1
                        if deleteCount == documents.count && !failed {
                            print("Event and related userEvents deleted successfully.")
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
}
