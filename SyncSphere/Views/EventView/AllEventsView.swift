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
    @State private var selectedTab: Tab = .inprogress

    private var userId: String? {
        profileViewModel.user?.id
    }
            var body: some View {
                VStack {
                    // Top Tab Picker
                    Picker("Select a tab", selection: $selectedTab) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

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
                            List(filteredEvents) { event in
                                Text(event.eventName)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationTitle("Events")
                .onAppear(perform: loadEvents)
                .refreshable {
                    loadEvents()
                }
            }
    
    private func eventsForSelectedTab() -> [SyncEvent] {
        switch selectedTab {
        case .completed:
            return events.filter { $0.statusId == 1 }
        case .upcoming:
            return events.filter { $0.statusId == 2 }
        case .cancelled:
            return events.filter { $0.statusId == 3 }
        case .inprogress:
            return events.filter { $0.statusId == 4 }
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
