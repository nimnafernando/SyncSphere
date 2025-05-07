//
//  AllEventsView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import SwiftUI

struct AllEventsView: View {
    
    enum Tab: String, CaseIterable {
        case inprogress = "Ongoing"
        case upcoming = "Upcoming"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
    
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var viewModel = EventViewModel()
    private let eventKitManager = EventKitManager()
    @State private var events: [SyncEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPopup = false
    @State private var selectedEvent: SyncEvent? = nil
    @State private var eventToDelete: SyncEvent? = nil
    @State private var isShowingEventDetail = false
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    @State private var refreshID = UUID()
    
    private var userId: String? {
        profileViewModel.user?.id
    }
    
    var initialTab: Tab = .inprogress
    @State private var selectedTab: Tab
    
    init(initialTab: Tab = .inprogress) {
        self.initialTab = initialTab
        _selectedTab = State(initialValue: initialTab)
    }
    
    var body: some View {
        ZStack {
            if showToast {
                VStack {
                    ToastView(message: toastMessage, type: toastType)
                        .padding(.top, 20)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
            
            VStack(spacing: 0) {
                // Tab bar
                HStack {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                            .font(.subheadline)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(selectedTab == tab ? Color("Lavendar") : Color.gray.opacity(0.1))
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedTab == tab ? Color("Lavendar") : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedTab = tab
                                }
                            }
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                
                // Content area
                ScrollView {
                    VStack(spacing: 12) {
                        if isLoading {
                            ProgressView("Loading events...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else if let error = errorMessage {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else {
                            let filteredEvents = eventsForSelectedTab()
                            if filteredEvents.isEmpty {
                                Text("No events found")
                                    .italic()
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredEvents) { event in
                                        NavigationLink(destination: EventDetailView(event: event)) {
                                            EventCard(
                                                title: event.eventName,
                                                date: event.dueDate,
                                                statusId: event.statusId ?? 1,
                                                onComplete: {
                                                    markEventAsCompleted(event)
                                                },
                                                onDelete: {
                                                    confirmDeleteEvent(event)
                                                },
                                                onTap: nil
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.vertical, 12)
                                .id(refreshID) 
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(destination: NewEventView())
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            PopupView(
                title: "Delete Event",
                message: eventToDelete?.statusId ?? 1 != 3 ? "This event will be moved to cancelled. Are you sure you want to remove this event?" : "This will permenantly remove all the event details of the event. Are you sure you want to delete this event?",
                isPresented: $showPopup,
                confirmButtonTitle: "Delete",
                cancelButtonTitle: "Cancel",
                onConfirm: {
                    if let event = eventToDelete {
                        performDeleteEvent(event)
                    }
                    eventToDelete = nil
                    showPopup = false
                },
                onCancel: {
                    eventToDelete = nil
                    showPopup = false
                }
            )
        )
        .navigationTitle("Events")
        .onAppear(perform: loadEvents)
        .refreshable {
            loadEvents()
        }
        .onChange(of: selectedTab) { newTab in
            loadEvents()
        }
    }
    
    private func eventsForSelectedTab() -> [SyncEvent] {
        switch selectedTab {
        case .completed:
            return events.filter { $0.statusId == 2 }
        case .upcoming:
            return events.filter { $0.statusId == 1 }
        case .cancelled:
            return events.filter { $0.statusId == 3 }
        case .inprogress:
            return events.filter { $0.statusId == 0 }
        }
    }
    
    private func loadEvents() {
        isLoading = true
        errorMessage = nil
        
        guard let userId = userId, !userId.isEmpty else {
            print("User ID is empty")
            isLoading = false
            errorMessage = "No user available"
            return
        }
        
        viewModel.getEventsForUser(userId: userId) { result in
            self.isLoading = false
            
            switch result {
            case .success(let fetchedEvents):
                print("Successfully loaded \(fetchedEvents.count) events")
                self.events = fetchedEvents
            case .failure(let error):
                print("Error loading events: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func markEventAsCompleted(_ event: SyncEvent) {
        if (event.statusId == 3 || event.statusId == 2) {
            var updatedEvent = event
            updatedEvent.statusId = 1
            
            if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                self.events.remove(at: index)
            }
            
            self.events.append(updatedEvent)
            forceRefreshView()
            
            viewModel.updateEventField(eventId: event.eventId!, fields: ["statusId": 1]) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        showToast = true
                        toastMessage = "Event restored successfully!"
                        toastType = .success
                    case .failure(let error):
                        if let index = self.events.firstIndex(where: { $0.id == updatedEvent.id }) {
                            self.events.remove(at: index)
                        }
                        self.events.append(event)
                        forceRefreshView()
                        
                        showToast = true
                        toastMessage = "Failed to restore the event: \(error.localizedDescription)"
                        toastType = .error
                    }
                }
            }
        } else {
            var updatedEvent = event
            updatedEvent.statusId = 2
            
            if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                self.events.remove(at: index)
            }
            
            self.events.append(updatedEvent)
            forceRefreshView()
            
            viewModel.updateEventField(eventId: event.eventId!, fields: ["statusId": 2]) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        showToast = true
                        toastType = .success
                        toastMessage = "Mark as completed"
                    case .failure(let error):
                        if let index = self.events.firstIndex(where: { $0.id == updatedEvent.id }) {
                            self.events.remove(at: index)
                        }
                        self.events.append(event)
                        forceRefreshView()
                        
                        showToast = true
                        toastType = .error
                        toastMessage = "Failed to update the event: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func confirmDeleteEvent(_ event: SyncEvent) {
        eventToDelete = event
        showPopup = true
    }
    
    func performDeleteEvent(_ event: SyncEvent) {
        if (event.statusId == 3) {
            // Create a local copy to be removed
            var eventToRemove = event
            
            if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                self.events.remove(at: index)
                forceRefreshView()
            }
            
            viewModel.deleteEvent(eventId: event.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        showToast = true
                        toastType = .success
                        toastMessage = "Event deleted successfully"
                    case .failure(let error):
                        // Add back event if deletion failed
                        self.events.append(eventToRemove)
                        forceRefreshView()
                        showToast = true
                        toastType = .error
                        toastMessage = "Failed to delete the event: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            // Create a local copy with updated status
            var updatedEvent = event
            updatedEvent.statusId = 3
            
            // remove the event from the local list
            if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                self.events.remove(at: index)
            }
            
            // updated event
            self.events.append(updatedEvent)
            forceRefreshView()
            
            viewModel.updateEventField(eventId: event.eventId!, fields: ["statusId": 3]) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        showToast = true
                        toastType = .success
                        toastMessage = "Event Moved to cancelled"
                    case .failure(let error):
                        // Restore original event on failure
                        if let index = self.events.firstIndex(where: { $0.id == updatedEvent.id }) {
                            self.events.remove(at: index)
                        }
                        self.events.append(event)
                        forceRefreshView()
                        
                        showToast = true
                        toastType = .error
                        toastMessage = "Failed to update the event: \(error.localizedDescription)"
                    }
                }
            }
        }
        
        // Remove from calendar if it exists
        if let calendarId = event.calendarEventId {
            eventKitManager.removeEventFromCalendar(identifier: calendarId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Removed from eventkit")
                    case .failure(_):
                        print("Failed to remove from eventkit")
                    }
                }
            }
        }
    }
    
    // Force the view to refresh
    private func forceRefreshView() {
        DispatchQueue.main.async {
            self.refreshID = UUID()
        }
    }
    
    private func refreshEvents() {
        loadEvents()
        forceRefreshView()
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
    return AllEventsView()
        .environmentObject(mockViewModel)
}
