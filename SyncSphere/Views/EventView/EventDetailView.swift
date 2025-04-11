//
//  EventDetailView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-12.
//

import SwiftUI
import EventKit

struct EventDetailView: View {
    var event: SyncEvent
    @State private var isAddingToCalendar = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var calendarEventId: String?
    private let eventKitManager = EventKitManager()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(event.eventName)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(event.dueDate.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                }
                .padding(.bottom, 5)


                // Calendar Button
                Button(action: {
                    addToCalendar()
                }) {
                    HStack {
                        Image(systemName: calendarEventId == nil ? "calendar.badge.plus" : "calendar.badge.checkmark")
                        Text(calendarEventId == nil ? "Add to Calendar" : "Added to Calendar")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.Lavendar)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isAddingToCalendar)
                .opacity(isAddingToCalendar ? 0.6 : 1.0)
                .overlay(
                    Group {
                        if isAddingToCalendar {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                )
            }
            .padding()
        }
        .navigationBarTitle("Event Details", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Calendar Event"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear {
            // Initialize state from stored value if available
            calendarEventId = event.calendarEventId
        }
    }


    private func addToCalendar() {
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

        eventKitManager.addEventToCalendar(syncEvent: event) { result in
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


// Preview
struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventDetailView(event: SyncEvent(
                eventId: "event123",
                eventName: "Annual Tech Conference",
                dueDate: Date().addingTimeInterval(3600 * 24 * 3).timeIntervalSince1970,
                venue: "Bay Convention Center, Room 42B",
                priority: 8,
                isOutdoor: false,
                statusId: 0,
                createdAt: Date().timeIntervalSince1970
            ))
        }
    }
}
