//
//  NewEventView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import SwiftUI

struct NewEventView: View {
    @State private var eventName = ""
          @State private var dueDate = Date()
          @State private var venue = ""
          @State private var priority = ""
          @State private var isOutdoor = false
          @State private var statusId = 0

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

               print("Event created: \(newEvent)")
               // You can now save `newEvent` to your backend or local store
           }
       }

#Preview {
    NewEventView()
}
