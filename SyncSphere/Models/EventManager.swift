import EventKit
import SwiftUI
import Firebase

class EventKitManager {
    private let eventStore = EKEventStore()
    
    // Request calendar access with completion handler
    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            // For iOS 17+
            eventStore.requestFullAccessToEvents { granted, error in
                if let error = error {
                    print("Error requesting calendar access: \(error)")
                }
                completion(granted)
            }
        } else {
            // For iOS 16 and earlier
            eventStore.requestAccess(to: .event) { granted, error in
                if let error = error {
                    print("Error requesting calendar access: \(error)")
                }
                completion(granted)
            }
        }
    }
    
    // Add SyncEvent to Calendar with completion handler
    func addEventToCalendar(syncEvent: SyncEvent, completion: @escaping (Result<String, Error>) -> Void) {
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        
        if authStatus != .authorized {
            requestAccess { granted in
                if granted {
                    self.createAndSaveEvent(syncEvent: syncEvent, completion: completion)
                } else {
                    let error = NSError(domain: "EventKitManager",
                                       code: 1,
                                       userInfo: [NSLocalizedDescriptionKey: "Calendar access denied"])
                    completion(.failure(error))
                }
            }
        } else {
            createAndSaveEvent(syncEvent: syncEvent, completion: completion)
        }
    }
    
    private func createAndSaveEvent(syncEvent: SyncEvent, completion: @escaping (Result<String, Error>) -> Void) {
        let calendarEvent = EKEvent(eventStore: eventStore)
        
        // Configure the event
        calendarEvent.title = syncEvent.eventName
        calendarEvent.startDate = Date(timeIntervalSince1970: syncEvent.dueDate)
        calendarEvent.endDate = Date(timeIntervalSince1970: syncEvent.dueDate + 3600)
        
        if let venue = syncEvent.venue {
            calendarEvent.location = venue
        }
        
        var notes = "Added from SyncSphere\n"
        notes += "Priority: \(syncEvent.priority ?? 0)\n"
        notes += "Outdoor: \(syncEvent.isOutdoor ? "Yes" : "No")\n"
        calendarEvent.notes = notes
        
        calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        if let priority = syncEvent.priority, priority >= 7 {
            let alarm = EKAlarm(relativeOffset: -3600)
            calendarEvent.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(calendarEvent, span: .thisEvent)
            completion(.success(calendarEvent.eventIdentifier))
        } catch {
            completion(.failure(error))
        }
    }
    
    func removeEventFromCalendar(identifier: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let event = eventStore.event(withIdentifier: identifier) else {
            print("Calendar event not found for ID: \(identifier)")
            let error = NSError(domain: "EventKitManager",
                                code: 2,
                                userInfo: [NSLocalizedDescriptionKey: "Event not found"])
            completion(.failure(error))
            return
        }

        do {
            try eventStore.remove(event, span: .thisEvent)
            print("Successfully removed event: \(identifier)")
            completion(.success(()))
        } catch {
            print("Failed to remove event: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

}
