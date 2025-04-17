//
//  NewEventView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import SwiftUI

struct NewEventView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var isAddingToCalendar = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var calendarEventId: String?
    private let eventKitManager = EventKitManager()

    @State private var eventName = ""
    @State private var dueDate = Date()
    @State private var venue = ""
    @State private var priority = ""
    @State private var isOutdoor = false
    @State private var statusId = 0
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    
    let statusOptions = ["Upcoming", "In Progress", "Completed", "Cancelled"]
    
    var body: some View {
        Form {
            Section(header: Text("Event Details")) {
                TextField("Event Name", text: $eventName)
                
                TextField("Venue", text: $venue)
                
                TextField("Priority (Number)", text: $priority)
                    .keyboardType(.numberPad)
                
                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                
                Toggle("Is Outdoor Event?", isOn: $isOutdoor)
                
                Picker("Status", selection: $statusId) {
                    ForEach(0..<statusOptions.count, id: \.self) { index in
                        Text(statusOptions[index])
                    }
                }
            }
            
            Section {
                Button("Save Event") {
                    saveEvent()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("New Event")
    }
    
    private func saveEvent() {
        guard let priorityValue = Int(priority) else {
            print("Invalid priority")
            return
        }
        
        let newEvent = SyncEvent(
            eventId: nil,
            eventName: eventName,
            dueDate: dueDate.timeIntervalSince1970,
            venue: venue,
            priority: priorityValue,
            isOutdoor: isOutdoor,
            statusId: statusId,
            createdAt: Date().timeIntervalSince1970
        )
        
        viewModel.addEventToFirestore(newEvent) { result in
            switch result {
            case .success():
                toastMessage = "Event added successfully!"
                toastType = .success
                showToast = true
                
                addToCalendar(SyncEvent: newEvent)
            case .failure(let error):
                toastMessage = "Failed to add event: \(error.localizedDescription)"
                toastType = .error
                showToast = true
            }
        }
        
    }
    
    private func addToCalendar(SyncEvent: SyncEvent) {
        // If already added, remove it
        if let existingId = calendarEventId {
            eventKitManager.removeEventFromCalendar(identifier: existingId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        calendarEventId = nil
                        alertMessage = "Event removed from calendar"
                        showAlert = true
                    case .failure(let error):
                        alertMessage = "Failed to remove: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
            return
        }
        
        // Otherwise add it
        isAddingToCalendar = true
        
        eventKitManager.addEventToCalendar(syncEvent: SyncEvent) { result in
            DispatchQueue.main.async {
                isAddingToCalendar = false
                
                switch result {
                case .success(let eventId):
                    calendarEventId = eventId
                    alertMessage = "Successfully added to calendar"
                case .failure(let error):
                    alertMessage = "Failed to add: \(error.localizedDescription)"
                }
                
                showAlert = true
            }
        }
    }
}

#Preview {
    NewEventView()
}
