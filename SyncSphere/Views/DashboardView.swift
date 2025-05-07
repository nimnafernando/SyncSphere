//
//  DashboardView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-08.
//

import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @StateObject private var eventViewModel = EventViewModel()
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var isSidebarVisible = false
    @State private var navigateToSignIn = false
    @State private var inProgressCount: Int = 0
    @State private var upcomingCount: Int = 0
    @State private var completedCount: Int = 0
    @State private var highestPriorityEvent: SyncEvent?
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    @State private var isLoading = true
    @State private var hasError = false
    @State private var viewAppeared = false
    @State private var showNotifications = false
    @State private var taskStats: (total: Int, completed: Int) = (0, 0)
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
      
                if showToast {
                    VStack {
                        ToastView(message: toastMessage, type: toastType)
                            .padding(.top, 20)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Loading your events...")
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: -40) {
                        
                        Rectangle()
                            .fill(Color.OffWhite)
                            .cornerRadius(40)
                            .frame(height: UIScreen.main.bounds.height * 0.51)
                            .overlay(
                                GeometryReader { geo in
                                    VStack(alignment: .leading) {
                                        
                                        Text("Coming Up")
                                            .font(.title3)
                                            .padding(.leading, 16)
                                        
                                        Text("\(highestPriorityEvent?.eventName ?? "No Events")")
                                            .font(.largeTitle)
                                            .bold()
                                            .padding(.leading, 16)
                                        
                                        HStack {
                                            Spacer()
                                            CountDown(dueDate:  Date(timeIntervalSince1970: highestPriorityEvent?.dueDate ?? 0))
                                            Spacer()
                                        }
                                        
                                        if let eventId = highestPriorityEvent?.eventId {
                                            CustomProgressBar(progress: taskStats.total > 0 ? CGFloat(taskStats.completed) / CGFloat(taskStats.total) : 0)
                                                .padding(.top, 6)
                                        }                                    }
                                    .padding(.top, UIScreen.main.bounds.height * 0.13)
                                    .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .ignoresSafeArea()
                        
                        VStack(alignment: .leading) {
                            
                            Text("Event Categories")
                                .font(.title3)
                            
                            NavigationLink(destination: AllEventsView(initialTab: .inprogress)) {
                                TaskCard(
                                    icon: "wrench.adjustable",
                                    iconColor: .Lavendar,
                                    title: "In Progress",
                                    subtitle: "Already Started Events",
                                    count: "\(inProgressCount)"
                                )
                            }
                            
                            NavigationLink(destination: AllEventsView(initialTab: .upcoming)) {
                                TaskCard(
                                    icon: "calendar",
                                    iconColor: .CustomPink,
                                    title: "Up Coming",
                                    subtitle: "Up Coming Events",
                                    count: "\(upcomingCount)"
                                )
                            }
                            
                            NavigationLink(destination: AllEventsView(initialTab: .completed)) {
                                TaskCard(
                                    icon: "checkmark.rectangle.stack",
                                    iconColor: .green,
                                    title: "Completed",
                                    subtitle: "Completed Events",
                                    count: "\(completedCount)"
                                )
                            }
                        }
                        Spacer()
                        
                        FloatingActionButton(destination: NewEventView())

                    }
                }
                // Sidebar button at top-right
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            isSidebarVisible.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 22))
                            .foregroundColor(Color.black)
                        }.padding(.leading, 18)
                    
                    Spacer()
                    
                    Button(action: {
                        showNotifications = true
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 22))
                            .foregroundColor(Color.Lavendar)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.Lavendar.opacity(0.3))
                            ).padding(.trailing, 16)
                    }
                }
                // Overlay for sidebar background
                if isSidebarVisible {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isSidebarVisible = false
                            }
                        }
                }
                
                // Sidebar panel
                SideBarView(isVisible: $isSidebarVisible, navigateToSignIn: $navigateToSignIn)
                                    .environmentObject(profileViewModel)
            }
            .task {
                await loadAllData()
            }

            .frame(maxWidth: .infinity)
            .navigationDestination(isPresented: $navigateToSignIn) {
                SignInView()
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationView().environmentObject(profileViewModel)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func loadAllData() async {
        isLoading = true
        hasError = false
        
        guard (profileViewModel.user?.id) != nil else {
            isLoading = false
            hasError = true
            toastMessage = "User information not available"
            toastType = .error
            showToast = true
            return
        }
        
        // Use async/await for better flow control
        await withTaskGroup(of: Void.self) { group in
            // Load in-progress events
            group.addTask {
                await loadEventsWithStatus(statusId: 0) { result in
                    if case .success(let events) = result {
                        DispatchQueue.main.async {
                            inProgressCount = events.count
                        }
                    } else if case .failure = result {
                        DispatchQueue.main.async {
                            hasError = true
                        }
                    }
                }
            }
            
            // Load upcoming events
            group.addTask {
                await loadEventsWithStatus(statusId: 1) { result in
                    if case .success(let events) = result {
                        DispatchQueue.main.async {
                            upcomingCount = events.count
                        }
                    } else if case .failure = result {
                        DispatchQueue.main.async {
                            hasError = true
                        }
                    }
                }
            }
            
            // Load completed events
            group.addTask {
                await loadEventsWithStatus(statusId: 2) { result in
                    if case .success(let events) = result {
                        DispatchQueue.main.async {
                            completedCount = events.count
                        }
                    } else if case .failure = result {
                        DispatchQueue.main.async {
                            hasError = true
                        }
                    }
                }
            }
            
        }
        // Load highest priority event first
        await loadHighestPriorityEventAsync()
        
        // Then load task stats for the highest priority event
        if let eventId = highestPriorityEvent?.eventId {
            do {
                let stats = try await taskViewModel.getTaskCompletionStats(for: eventId)
                await MainActor.run {
                    taskStats = stats
                }
            } catch {
                print("Error loading task stats: \(error)")
            }
        }
        
        DispatchQueue.main.async {
            isLoading = false
            if hasError {
                toastMessage = "Some data couldn't be loaded"
                toastType = .error
                showToast = true
            }
        }
    }

    // Convert your existing methods to support async/await
    private func loadEventsWithStatus(statusId: Int, completion: @escaping (Result<[SyncEvent], Error>) -> Void) async {
        guard let userId = profileViewModel.user?.id else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not available"])))
            return
        }
        
        // Use a continuation to bridge callback-based API with async/await
        await withCheckedContinuation { continuation in
            eventViewModel.getEventsForUser(userId: userId) { result in
                switch result {
                case .success(let allEvents):
                    let filteredEvents = allEvents.filter { $0.statusId == statusId }
                    print("Filtered \(allEvents.count) events to \(filteredEvents.count) with status ID \(statusId)")
                    completion(.success(filteredEvents))
                case .failure(let error):
                    completion(.failure(error))
                }
                continuation.resume()
            }
        }
    }

    private func loadHighestPriorityEventAsync() async {
        guard let userId = profileViewModel.user?.id else { return }
        
        await withCheckedContinuation { continuation in
            eventViewModel.getHighestPriorityEvent(userId: userId) { result in
                switch result {
                case .success(let event):
                    DispatchQueue.main.async {
                        self.highestPriorityEvent = event
                        if let event = event {
                            print("Highest priority event: \(event.eventName)")
                        } else {
                            print("No events found")
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        toastMessage = "Couldn't fetch priority event"
                        toastType = .error
                        showToast = true
                        print("Error fetching highest priority event: \(error)")
                    }
                }
                continuation.resume()
            }
        }
    }
}

#Preview {
    let previewProfileVM = ProfileViewModel()
    previewProfileVM.user = SyncUser(id: "preview", username: "User", email: "test@example.com", createdAt: Date().timeIntervalSince1970)
    
    return DashboardView()
        .environmentObject(previewProfileVM)
}
