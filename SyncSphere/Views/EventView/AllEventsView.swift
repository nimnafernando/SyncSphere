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
    @State private var events: [SyncEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var selectedEvent: SyncEvent? = nil
    @State private var isShowingEventDetail = false
    
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
            GradientBackground()
            mainContent
        }
    }
    
    private var mainContent: some View {
        VStack {
            tabBar
            eventList
            Spacer()
            FloatingActionButton(destination: NewEventView())
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Events")
        .onAppear(perform: loadEvents)
        .refreshable {
            loadEvents()
        }
    }
    
    private var tabBar: some View {
        HStack() {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, 8)
    }
    
    private func tabButton(for tab: Tab) -> some View {
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
    
    private var eventList: some View {
        ScrollView {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else {
                eventsContent
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView("Loading events...")
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func errorView(_ error: String) -> some View {
        Text("Error: \(error)")
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var eventsContent: some View {
        let filteredEvents = eventsForSelectedTab()
        if filteredEvents.isEmpty {
            return AnyView(
                Text("No events found")
                    .italic()
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            )
        } else {
            return AnyView(
                LazyVStack(spacing: 12) {
                    ForEach(filteredEvents) { event in
                        eventRow(for: event)
                    }
                }
                .padding(.horizontal)
            )
        }
    }
    
    private func eventRow(for event: SyncEvent) -> some View {
        NavigationLink(destination: EventDetailView(event: event)) {
            EventCard(
                title: event.eventName,
                date: event.dueDate,
                statusId: event.statusId ?? 1,
                onComplete: {
                    markEventAsCompleted(event)
                },
                onDelete: {
                    deleteEvent(event)
                },
                onTap: nil
            )
        }
        .buttonStyle(PlainButtonStyle())
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
            print("User ID is nil or empty")
            isLoading = false
            errorMessage = "No user ID available"
            return
        }
        
        print("Loading events for user ID: \(userId)")
        
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
        print("event", event)
    }
    
    func deleteEvent(_ event: SyncEvent) {
        print("event", event)
    }
    
    func navigateToEventDetail(_ event: SyncEvent) {
        selectedEvent = event
        isShowingEventDetail = true
    }
}


#Preview {
    let mockViewModel = ProfileViewModel()
    mockViewModel.user = SyncUser(
        id: "123",
        username: "Jane Doe",
        email: "jane@example.com",
        createdAt: Date().timeIntervalSince1970
    )
    return AllEventsView()
        .environmentObject(mockViewModel)
}

