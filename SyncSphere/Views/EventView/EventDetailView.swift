//
//  EventDetailView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-03.
//

import SwiftUI

struct EventDetailView: View {
    let event: SyncEvent
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Event Name
                    Text(event.eventName)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    
                    // Event Details
                    VStack(alignment: .leading, spacing: 15) {
                        DetailRow(icon: "calendar", title: "Due Date", value: formatDate(event.dueDate))
                        DetailRow(icon: "mappin.and.ellipse", title: "Venue", value: event.venue ?? "You can add event location")
                        DetailRow(icon: "flag.fill", title: "Priority", value: "\(event.priority)")
                        DetailRow(icon: "location.fill", title: "Location Type", value: event.isOutdoor ? "Outdoor" : "Indoor")
                        DetailRow(icon: "checkmark.circle.fill", title: "Status", value: getStatusText(event.statusId ?? 1))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func getStatusText(_ statusId: Int) -> String {
        switch statusId {
        case 0: return "In Progress"
        case 1: return "Upcoming"
        case 2: return "Completed"
        case 3: return "Cancelled"
        default: return "Unknown"
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.Lavendar)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    let mockEvent = SyncEvent(
        eventId: "evt001",
        eventName: "Team Meeting",
        dueDate: Date().timeIntervalSince1970,
        venue: "Colombo",
        priority: 1,
        isOutdoor: false,
        statusId: 1,
        createdAt: Date().timeIntervalSince1970
    )
    return NavigationStack {
        EventDetailView(event: mockEvent)
    }
}
