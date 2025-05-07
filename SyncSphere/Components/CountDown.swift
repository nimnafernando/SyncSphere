//
//  CountDownView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

struct CountDown: View {
    let dueDate : Date
    
    @State private var timeRemaining: DateComponents = DateComponents()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 12) {
            
            HStack() {
                timeBox(title: "Days", value: timeRemaining.day ?? 0)
                Divider()
                    .frame(height: 14)
                    .background(Color.gray)
                    .rotationEffect(.degrees(90))
                timeBox(title: "Hours", value: timeRemaining.hour ?? 0)
                Divider()
                    .frame(height: 14)
                    .background(Color.gray)
                    .rotationEffect(.degrees(90))
                timeBox(title: "Minutes", value: timeRemaining.minute ?? 0)
            }
        }
        .onAppear {
            updateCountdown()
        }
        .onReceive(timer) { _ in
            updateCountdown()
        }
    }
    
    private func updateCountdown() {
        let now = Date()
        
        if dueDate <= now || dueDate == Date(timeIntervalSince1970: 0) {
            timeRemaining = DateComponents(day: 0, hour: 0, minute: 0)
        } else {
            let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: dueDate)
            timeRemaining = diff
        }
    }
    
    
    private func timeBox(title: String, value: Int) -> some View {
        VStack {
            Text(String(format: "%02d", value))
                .font(.system(size: 46, weight: .bold))
                .frame(minWidth: UIScreen.main.bounds.width * 0.21)
                .padding(.vertical, 20)
                .padding(.horizontal, 2)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 2.4)
                )
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    CountDown(dueDate: Date())
}
