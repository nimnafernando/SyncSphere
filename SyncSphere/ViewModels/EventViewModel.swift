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
    
    func getEventsForUser(userId: String, completion: @escaping (Result<[SyncEvent], Error>) -> Void) {
        print("Starting to fetch events for userId: \(userId)")
        
        // Create a reference to the user document
        let userRef = db.collection("user").document(userId)
        print("Created user reference: \(userRef)")
        
        // Query using the reference instead of a string
        db.collection("userEvents")
            .whereField("userId", isEqualTo: userRef)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching userEvents: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found in userEvents collection")
                    completion(.success([]))
                    return
                }
                
                print("Found \(documents.count) userEvent documents")
                
                if documents.isEmpty {
                    completion(.success([]))
                    return
                }
                
                // Extract event references
                let eventRefs = documents.compactMap { doc -> DocumentReference? in
                    guard let eventRef = doc.data()["eventId"] as? DocumentReference else {
                        print("Could not find eventId reference in document \(doc.documentID)")
                        return nil
                    }
                    
                    print("Found event reference: \(eventRef)")
                    return eventRef
                }
                
                print("Extracted \(eventRefs.count) event references")
                
                if eventRefs.isEmpty {
                    print("No valid event references found")
                    completion(.success([]))
                    return
                }
                
                // Now fetch all these events
                let group = DispatchGroup()
                var events: [SyncEvent] = []
                var fetchError: Error?
                
                for eventRef in eventRefs {
                    group.enter()
                    
                    eventRef.getDocument { snapshot, error in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("Error fetching event \(eventRef.documentID): \(error)")
                            fetchError = error
                            return
                        }
                        
                        if snapshot?.exists == false {
                            print("Event document \(eventRef.documentID) does not exist")
                            return
                        }
                        
                        guard let data = snapshot?.data() else {
                            print("No data found for event \(eventRef.documentID)")
                            return
                        }
                        
                        print("Retrieved data for event \(eventRef.documentID): \(data)")
                        
                        // Create event manually instead of using decoder
                        do {
                            // Extract status ID
                            var statusIdValue: Int?
                            if let statusRef = data["statusId"] as? DocumentReference {
                                print("Status reference: \(statusRef)")
                                // Extract statusId from the path or fetch from Firestore if needed
                                // For now, we'll use the last component of the path
                                let pathComponents = statusRef.path.components(separatedBy: "/")
                                if let lastComponent = pathComponents.last, let id = Int(lastComponent) {
                                    statusIdValue = id
                                } else {
                                    // If we can't parse the ID, use the document ID as a fallback
                                    statusIdValue = Int(statusRef.documentID) ?? 0
                                }
                            } else if let statusId = data["statusId"] as? Int {
                                statusIdValue = statusId
                            }
                            
                            // Extract dates
                            var dueDate: TimeInterval = 0
                            if let timestamp = data["dueDate"] as? Timestamp {
                                dueDate = TimeInterval(timestamp.seconds)
                            } else if let dateDouble = data["dueDate"] as? Double {
                                dueDate = dateDouble
                            } else if let dateInt = data["dueDate"] as? Int {
                                dueDate = TimeInterval(dateInt)
                            }
                            
                            var createdAt: TimeInterval?
                            if let timestamp = data["createdAt"] as? Timestamp {
                                createdAt = TimeInterval(timestamp.seconds)
                            } else if let dateDouble = data["createdAt"] as? Double {
                                createdAt = dateDouble
                            } else if let dateInt = data["createdAt"] as? Int {
                                createdAt = TimeInterval(dateInt)
                            }
                            
                            // Handle boolean field that might be stored as 0/1
                            var isOutdoor = false
                            if let boolValue = data["isOutdoor"] as? Bool {
                                isOutdoor = boolValue
                            } else if let intValue = data["isOutdoor"] as? Int {
                                isOutdoor = intValue != 0
                            }
                            
                            // Create the event
                            let event = SyncEvent(
                                eventId: eventRef.documentID,
                                eventName: data["eventName"] as? String ?? "Unknown Event",
                                dueDate: dueDate,
                                venue: data["venue"] as? String,
                                priority: data["priority"] as? Int,
                                isOutdoor: isOutdoor,
                                statusId: statusIdValue,
                                createdAt: createdAt
                            )
                            
                            print("Successfully created event: \(event.eventName)")
                            events.append(event)
                        } catch {
                            print("Error creating event \(eventRef.documentID): \(error)")
                            fetchError = error
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    print("All event fetches completed. Events count: \(events.count)")
                    if let error = fetchError {
                        completion(.failure(error))
                    } else {
                        completion(.success(events))
                    }
                }
            }
    }

    // Helper method to process event data
    private func processEventData(_ eventId: String, _ data: [String: Any], _ events: inout [SyncEvent], _ fetchError: inout Error?) {
        print("Retrieved data for event \(eventId): \(data)")
        
        do {
            // Add the eventId to the data dictionary
            var eventData = data
            eventData["eventId"] = eventId
            
            print("Attempting to decode event data: \(eventData)")
            
            // Convert to JSON and decode
            let jsonData = try JSONSerialization.data(withJSONObject: eventData)
            let event = try JSONDecoder().decode(SyncEvent.self, from: jsonData)
            print("Successfully decoded event: \(event.eventName)")
            events.append(event)
        } catch {
            print("Error decoding event \(eventId): \(error)")
            print("Data: \(data)")
            fetchError = error
        }
    }
}
