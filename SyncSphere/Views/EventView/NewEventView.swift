//
//  NewEventView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import SwiftUI

struct NewEventView: View {
    
    @StateObject private var viewModel = EventViewModel()
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var isAddingToCalendar = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var calendarEventId: String?
    private let eventKitManager = EventKitManager()
    
    @State private var eventName = ""
    @State private var dueDate = Date()
    @State private var venue = ""
    @State private var isOutdoor = false
    @State private var isOngoing: Bool = false
    @State private var selectedPriority: Int = 4
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    let priorities: [(title: String, value: Int, color: Color)] = [
        ("High", 1, .red),
        ("Medium", 2, .blue),
        ("Low", 3, .green),
        ("default", 4, .lavendar)
    ]
    
    @Environment(\.dismiss) private var dismiss
    var existingEvent: SyncEvent? = nil
    
    var body: some View {
        
        NavigationStack{
            ZStack{
                
                if showToast {
                    VStack {
                        ToastView(message: toastMessage, type: toastType)
                            .padding(.top, 20)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showToast = false
                                    }
                                }
                            }
                        Spacer()
                    }
                    .zIndex(1)
                }
                
                GradientBackground()
                
                VStack() {
                    Text(existingEvent != nil ? "Edit Event" : "New Event")
                        .font(.title)
                        .bold()
                    
                    
                    VStack() {
                        ClassicText(text: $eventName, placeholder: "Event Name")
                            .padding(.top, 20)
                        
                        DatePicker("Due Date", selection: $dueDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                        
                    }
                    .background(Color.OffWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(10)
                    
                    
                    VStack() {
                        ClassicText(text: $venue, placeholder: "Venue")
                            .padding(.top, 20)
                        
                        HStack {
                            Toggle("", isOn: $isOutdoor)
                                .labelsHidden()
                            Text("Outdoor")
                                .foregroundColor(.black)
                                .padding(.leading, 10)
                            
                            Spacer()
                            
                            NavigationLink(destination: WeatherForcastView()) {
                                Text("See Details")
                                    .foregroundColor(Color.blue)
                                    .font(.footnote)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                    .background(Color.OffWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(10)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Event Priority")
                            .padding(.leading, 24)
                            .padding(.top, 20)
                        HStack() {
                            ForEach(priorities, id: \.value) { priority in
                                Button(action: {
                                    selectedPriority = priority.value
                                }) {
                                    Text(priority.title)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(
                                            selectedPriority == priority.value
                                            ? priority.color
                                            : Color.white.opacity(0.9)
                                        )
                                        .foregroundColor(
                                            selectedPriority == priority.value
                                            ? .white
                                            : priority.color
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 40)
                                                .stroke(priority.color, lineWidth: 1)
                                        )
                                    
                                        .cornerRadius(40)
                                    
                                }
                            }
                            .padding(.top, 20)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        
                        HStack {
                            Toggle("", isOn: $isOngoing)
                                .labelsHidden()
                            Text("Mark as Ongoing")
                                .foregroundColor(.black)
                                .padding(.leading, 10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        
                    }
                    .background(Color.OffWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(10)
                    
                    Spacer()
                    HStack(){
                        BorderedButton(label: "Clear All", width: 0.4, action: clearAll)
                            .padding(.leading, 20)
                        AuthButton(label: existingEvent != nil ? "Update Event" : "Save Event", width: 0.4 ){
                            saveEvent()
                        }
                        
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .onAppear {
                loadEventData()
            }
            .id(existingEvent?.id)
        }
    }
    
    private func loadEventData() {
        guard let event = existingEvent else { return }
        eventName = event.eventName
        dueDate = Date(timeIntervalSince1970: event.dueDate)
        venue = event.venue ?? ""
        isOutdoor = event.isOutdoor
        isOngoing = event.statusId == 0 ? true : false
        selectedPriority = event.priority ?? 4
    }
    
    private func saveEvent() {
        guard !eventName.trimmingCharacters(in: .whitespaces).isEmpty else {
            toastMessage = "Event name is required."
            toastType = .error
            showToast = true
            return
        }
        
        // Determine if this is a new event or an update
        let isUpdate = existingEvent != nil
        
        let eventToSave = SyncEvent(
            eventId: existingEvent?.eventId,
            eventName: eventName,
            dueDate: dueDate.timeIntervalSince1970,
            venue: venue,
            priority: selectedPriority,
            isOutdoor: isOutdoor,
            statusId: isOngoing == true ? 0 : 1,
            createdAt: existingEvent?.createdAt ?? Date().timeIntervalSince1970,
            calendarEventId: existingEvent?.calendarEventId ?? nil
        )
        
        viewModel.addEventToFirestore(eventToSave) { result in
            switch result {
            case .success(let eventId):
                toastMessage = isUpdate ? "Event updated successfully!" : "Event added successfully!"
                toastType = .success
                showToast = true
                
                if !isUpdate {
                    guard let userId = profileViewModel.user?.id else {
                        print("User ID not available")
                        return
                    }
                    viewModel.addUserEventRecord(userId: userId , eventId: eventId) { userEventResult in
                        if case .failure(let error) = userEventResult {
                            print("Failed to create userEvent: \(error.localizedDescription)")
                        }
                    }
                }
                
                addToCalendar(SyncEvent: eventToSave, createdEventId: eventId)
                NotificationCenter.default.post(name: NSNotification.Name("EventUpdated"), object: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            case .failure(let error):
                toastMessage = isUpdate ? "Failed to update event: \(error.localizedDescription)" : "Failed to add event: \(error.localizedDescription)"
                toastType = .error
                showToast = true
            }
        }
    }
    
    private func addToCalendar(SyncEvent: SyncEvent, createdEventId: String) {
        // If already added, remove
        if let calendarId = SyncEvent.calendarEventId {
            eventKitManager.removeEventFromCalendar(identifier: SyncEvent.calendarEventId ?? calendarId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        alertMessage = "Event removed from calendar"
                        showAlert = true
                    case .failure(let error):
                        alertMessage = "Failed to remove: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
        }
        
        isAddingToCalendar = true
        
        eventKitManager.addEventToCalendar(syncEvent: SyncEvent) { result in
            DispatchQueue.main.async {
                isAddingToCalendar = false
                
                switch result {
                case .success(let eventId):
                    alertMessage = "Successfully added to calendar"
                    print("calendar id: ", eventId)
                    // Save EventKit calendar identifier
                    if let syncId = SyncEvent.eventId {
                        let fields: [String: Any] = ["calendarEventId": eventId]
                        viewModel.updateEventField(eventId: syncId, fields: fields) { result in
                            switch result {
                            case .success:
                                print("calendarEventId updated in Firestore")
                            case .failure(let error):
                                print("Failed to update Firestore: \(error.localizedDescription)")
                            }
                        }
                    }

                case .failure(let error):
                    alertMessage = "Failed to add: \(error.localizedDescription)"
                }
                
                showAlert = true
            }
            viewModel.updateEventField(eventId: createdEventId, fields: ["calendarEventId": calendarEventId ?? ""]) { result in
                switch result {
                case .success:
                    print("calendarEventId updated in Firestore")
                case .failure(let error):
                    print("Failed to update Firestore: \(error.localizedDescription)")
                }
            }
        }
    }

    
    private func clearAll() {
        eventName = ""
        dueDate = Date()
        venue = ""
        isOutdoor = false
        isOngoing = false
        selectedPriority = 4
    }
}

#Preview {
    let mockViewModel = ProfileViewModel()
    mockViewModel.user = SyncUser(
        id: "123",
        username: "abc def",
        email: "abcdef@example.com",
        createdAt: Date().timeIntervalSince1970
    )
    
    let mockEvent = SyncEvent(
        eventId: "event123",
        eventName: "Sample Event",
        dueDate: Date().addingTimeInterval(3600).timeIntervalSince1970,
        venue: "Sample Venue",
        priority: 2,
        isOutdoor: true,
        statusId: 1,
        createdAt: Date().timeIntervalSince1970,
        calendarEventId: nil
    )
    
    return NewEventView(existingEvent: mockEvent)
        .environmentObject(mockViewModel)
}

