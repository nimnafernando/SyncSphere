//
//  HelpView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

struct HelpView: View {
    
    @State private var currentCardIndex = 0
       
       // help cards
       let helpCards: [HelpCard] = [
           HelpCard(
               title: "Welcome to SyncSphere!",
               image: "calculator",
               content: "Enjoy a bright, user-friendly interface with playful colors designed to boost focus and creativity 🌈"
           ),
           HelpCard(
               title: "Task and Event Management",
               image: "book",
               content: "Swipe Left on any Task or Event to Edit or Delete it."
           ),
           HelpCard(
               title: "Task and Event Completion",
               image: "reference",
               content: "Swipe Right to Mark as Completed — keep track of what’s done!"
           ),
           HelpCard(
               title: "Quick View",
               image: "troubleshooting",
               content: "Tap on an Event to view its Tasks, Budget, and Timeline."
           ),
           HelpCard(
               title: "Keep updated",
               image: "faq",
               content: "Use the Calendar Integration to sync your upcoming events and stay on schedule"
           ),
           HelpCard(
               title: "Tips and Best Practices",
               image: "cloud",
               content: "Color-coded priorities help you quickly spot high, medium, and low priority tasks"
           ),
           HelpCard(
               title: "Event Management",
               image: "compliant",
               content: "Once you delete an event it will move into cancelled, you can permenently delete an event from cancelled events."
           ),
           HelpCard(
               title: "Task Category Management",
               image: "compliant",
               content: "You cannot delete an event category if its in use under a task, first you might need to remove it from the tasks to delete the category."
           ),
           HelpCard(
               title: "Search Event",
               image: "compliant",
               content: "Use the Search Bar to quickly find events or tasks by name."
           ),
           HelpCard(
               title: "Version and Credits",
               image: "customer-service",
               content: "Version 1.0.0\nSupports IOS 16+\nBuilt with SwiftUI and Xcode."
           )
       ]
       
       var body: some View {
           ScrollView{
               VStack {
                   // Card counter
                   Text("\(currentCardIndex + 1) / \(helpCards.count)")
                       .font(.caption)
                       .padding(.top)
                   
                   // Card
                   TabView(selection: $currentCardIndex) {
                       ForEach(0..<helpCards.count, id: \.self) { index in
                           CardView(card: helpCards[index])
                               .tag(index)
                       }
                   }
                   .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                   .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                   .frame(height: UIScreen.main.bounds.height * 0.65)
                   
                   // Navigations
                   HStack {
                       Button(action: {
                           withAnimation {
                               currentCardIndex = max(currentCardIndex - 1, 0)
                           }
                       }) {
                           Image(systemName: "chevron.left")
                               .font(.title2)
                               .padding()
                               .foregroundColor(currentCardIndex > 0 ? (.black) : .gray)
                       }
                       .disabled(currentCardIndex == 0)
                       
                       Button(action: {
                           withAnimation {
                               currentCardIndex = min(currentCardIndex + 1, helpCards.count - 1)
                           }
                       }) {
                           Image(systemName: "chevron.right")
                               .font(.title2)
                               .padding()
                               .foregroundColor(currentCardIndex < helpCards.count - 1 ? (.black) : .gray)
                       }
                       .disabled(currentCardIndex == helpCards.count - 1)
                   }
                   .padding(.horizontal)
               }
               .navigationTitle("Help")
               .foregroundColor( Color.black)
           }.background( Color.white)
               
       }
}

struct HelpCard {
    let title: String
    let image: String
    let content: String
}

// card view
struct CardView: View {
    let card: HelpCard
    
    var body: some View {
        VStack {
            Image(card.image)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.2)
                .foregroundColor(.black)
                .padding(.top, 20)
                .padding(.bottom, 30)
            
            // Card content
            VStack(alignment: .leading, spacing: 20) {
                Text(card.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                
                Text(card.content)
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

#Preview {
    HelpView()
}
