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
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEvents) { event in
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        EventCard(
                                            title: event.eventName,
                                            date: event.dueDate,
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
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
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
