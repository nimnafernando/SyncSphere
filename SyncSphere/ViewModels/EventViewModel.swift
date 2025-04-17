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
                            
                        } catch {
                            print("Error parsing event \(eventRef.documentID): \(error)")
                            errors.append(error)
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if !errors.isEmpty {
                        print("Completed with \(errors.count) error(s)")
                    } else {
                        print("Successfully fetched \(events.count) event(s)")
                    }
                    
                    completion(.success(events))
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
                if events.isEmpty {
                    // No events found
                    completion(.success(nil))
                    return
                }
                
                // Sort events by due date (latest first)
                let sortedEvents = events.sorted { (event1, event2) -> Bool in
                    // Compare due dates (latest first)
                    if event1.dueDate != event2.dueDate {
                        return event1.dueDate > event2.dueDate
                    }
                    
                    // If due dates are equal, compare creation dates (earliest first)
                    let created1 = event1.createdAt ?? 0
                    let created2 = event2.createdAt ?? 0
                    return created1 < created2
                }
                
                // Get the first event after sorting
                if let highestPriorityEvent = sortedEvents.first {
                    print("Highest priority event: \(highestPriorityEvent.eventName), dueDate: \(Date(timeIntervalSince1970: highestPriorityEvent.dueDate))")
                    completion(.success(highestPriorityEvent))
                } else {
                    completion(.success(nil))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func addEventToFirestore(_ event: SyncEvent, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        do {
            let documentRef: DocumentReference
            if let eventId = event.eventId {
                documentRef = db.collection("event").document(eventId)
            } else {
                documentRef = db.collection("event").document()
            }
            
            var newEvent = event
            newEvent.eventId = documentRef.documentID
            
            try documentRef.setData(from: newEvent) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("Event added with ID: \(documentRef.documentID)")
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
}
