//
//  EventCard.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-20.
//

import SwiftUI

struct EventCard: View {
    let title: String
    let date: TimeInterval
    let statusId : Int

    var onComplete: (() -> Void)?
     var onDelete: (() -> Void)?
     var onTap: (() -> Void)?
     
     @State private var offset: CGFloat = 0
     
     var body: some View {
         ZStack {
             ZStack {
                 // Complete action
                 Rectangle()
                     .foregroundColor(statusId == 3 ? .blue : .green)
                     .cornerRadius(20)
                     .frame(width: UIScreen.main.bounds.width * 0.9)
                     .overlay(
                         HStack {
                             Spacer()
                             Image(systemName: statusId == 3 || statusId == 2 ? "repeat.circle" : "checkmark.circle.fill")
                                 .foregroundColor(.white)
                     
                         }
                         .padding(.trailing, 20)
                     )
                     .frame(height: UIScreen.main.bounds.height*0.1)
                     .padding(.bottom, 10)
                     .opacity(offset < 0 ? 1 : 0)
                 
                 // Delete action
                 Rectangle()
                     .foregroundColor(.red)
                     .cornerRadius(20)
                     .frame(width: UIScreen.main.bounds.width * 0.9)
                     .overlay(
                         HStack {
                       
                             Image(systemName: "trash.fill")
                                 .foregroundColor(.white)
                             Spacer()
                         }
                         .padding(.leading, 20)
                     )
                     .frame(height: UIScreen.main.bounds.height*0.1)
                     .padding(.bottom, 10)
                     .opacity(offset > 0 ? 1 : 0)
             
             }
             
             // Card content 
             Rectangle()
                 .fill(Color.white)
                 .cornerRadius(20)
                 .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1)
                 .overlay(
                     HStack {
                         VStack(alignment: .leading) {
                             Text(title)
                                 .font(.title2)
                                 .bold()
                             
                             HStack {
                                 Image(systemName: "calendar")
                                     .font(.system(size: 18))
                                     .foregroundColor(.gray)
                                
                                 Text(DateFormatExtension.formatDate(from: date))
                                     .foregroundColor(.gray)
                                     .font(.caption)
                                     .padding(.bottom, 2)
                             }
                         }
                         
                         Spacer()
                         
                         CircularProgressView(current: 5, total: 8)
                     }
                     .padding(20)
                 )
                 .offset(x: offset)
                 .gesture(
                     DragGesture()
                         .onChanged { gesture in
                             self.offset = gesture.translation.width / 2.2
                         }
                        .onEnded { gesture in
                            let threshold: CGFloat = 80
                            
                            if offset < -threshold {
                                // Swiped left (showing right side) - mark as completed
                                withAnimation {
                                    self.offset = -UIScreen.main.bounds.width * 0.1
                                }
                                
                                // Small delay before triggering action and resetting
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.onComplete?()
                                    
                                    // Reset after a slight delay
                                    withAnimation {
                                        self.offset = 0
                                    }
                                }
                            } else if offset > threshold {
                                // Swiped right (showing left side) - delete
                                withAnimation {
                                    self.offset = UIScreen.main.bounds.width * 0.1
                                }
                                
                                // Small delay before triggering action and resetting
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.onDelete?()
                                    
                                    // Reset after a slight delay
                                    withAnimation {
                                        self.offset = 0
                                    }
                                }
                            } else {
                                withAnimation(.spring()) {
                                    self.offset = 0
                                }
                            }
                        }
                 )
                 .padding(.bottom, 10)
         }
     }
}
                     
 


#Preview {
    EventCard(title: "Title", date: 12.00, statusId: 1)
}
