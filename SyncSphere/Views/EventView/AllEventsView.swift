//
//  AllEventsView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import SwiftUI

struct AllEventsView: View {
    
    enum Tab: String, CaseIterable {
        case inprogress = "InProgress"
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
        ZStack{
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
            VStack {
                
                HStack() {
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
                
                ScrollView{
                    // Event List Content
                    if isLoading {
                        ProgressView("Loading events...")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let error = errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        let filteredEvents = eventsForSelectedTab()
                        if filteredEvents.isEmpty {
                            Text("No events found")
                                .italic()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(filteredEvents) { event in
                                
                                EventCard(title: event.eventName, date: event.dueDate, statusId: event.statusId ?? 1,
                                          onComplete: {
                                    markEventAsCompleted(event)
                                },
                                          onDelete: {
                                    eventToDelete = event
                                    showPopup = true
                                },
                                          onTap: {
                                    selectedEvent = event
                                    isShowingEventDetail = true
                                })
                                
                            }
                        }
                        NavigationLink(
                            destination: NewEventView(existingEvent: selectedEvent),
                            isActive: $isShowingEventDetail,
                            label: { EmptyView() }
                        )
                    }
                }
                Spacer()
                FloatingActionButton(destination: NewEventView())
                    .onDisappear {
                    loadEvents()
                }
                
            } .overlay(
                PopupView(
                    title: "Delete Event",
                    message: eventToDelete?.statusId ?? 1 != 3 ? "This event will be moved to cancelled. Are you sure you want to remove this event?" : "This will permenantly remove all the event details of the event. Are you sure you want to delete this event?",
                    isPresented: $showPopup,
                    confirmButtonTitle: "Delete",
                    cancelButtonTitle: "Cancel",
                    onConfirm: {
                        if let event = eventToDelete {
                                deleteEvent(event)
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
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Events")
            .onAppear(perform: loadEvents)
            .refreshable {
                loadEvents()
            }
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
        if (event.statusId == 3){
            viewModel.updateEventField(eventId: event.eventId!, fields: ["statusId": 1]) { result in
                switch result {
                case .success():
                    showToast = true
                    toastMessage = "Event restored successfully!"
                    toastType = .success
                    refreshEvents()
                case .failure(let error):
                    showToast = true
                    toastMessage = "Failed to restore the event: \(error.localizedDescription)"
                    toastType = .error
                }
            }
        } else {
            viewModel.updateEventField(eventId: event.eventId!, fields: ["statusId": 2]) { result in
                switch result {
                case .success():
                    showToast = true
                    toastType = .success
                    toastMessage = "Mark as completed"
                    refreshEvents()
                case .failure(let error):
                    showToast = true
                    toastType = .error
                    toastMessage = "Failed to update the event: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteEvent(_ event: SyncEvent) {
        if (event.statusId == 3) {
            viewModel.deleteEvent(eventId: event.id) { result in
                switch result {
                case .success():
                    refreshEvents()
                    showToast = true
                    toastType = .success
                    toastMessage = "Event deleted successfully"
                case .failure(let error):
                    showToast = true
                    toastType = .error
                    toastMessage = "Failed to update the event: \(error.localizedDescription)"
                }
            }
        } else {
            viewModel.updateEventField(eventId: event.eventId!, fields: ["statusId": 3]) { result in
                switch result {
                case .success():
                    refreshEvents()
                    showToast = true
                    toastType = .success
                    toastMessage = "Event Moved to cancelled"
                case .failure(let error):
                    showToast = true
                    toastType = .success
                    toastMessage = "Failed to update the event: \(error.localizedDescription)"
                }
            }
        }
        if let calendarId = event.calendarEventId {
            eventKitManager.removeEventFromCalendar(identifier: event.calendarEventId ?? calendarId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Removed from eventkit")
                    case .failure(let error):
                        print("Faile to removed from eventkit")
                    }
                }
            }
        }
    }

    private func refreshEvents() {
        loadEvents()
        refreshID = UUID()

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
