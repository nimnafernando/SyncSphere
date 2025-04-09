//
//  CountDownView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

struct CountDown: View {
    let dueDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
//    let dueDate: Date = profileViewModel.profile?.dueDate ?? Date()

        @State private var timeRemaining: DateComponents = DateComponents()
        private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {

                HStack(spacing: 16) {
                    timeBox(title: "Days", value: timeRemaining.day ?? 0)
                    timeBox(title: "Hours", value: timeRemaining.hour ?? 0)
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
            let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: dueDate)
            timeRemaining = diff
        }

        private func timeBox(title: String, value: Int) -> some View {
            VStack {
                Text("\(value)")
                    .font(.system(size: 46, weight: .bold))
                    .frame(minWidth: 80)
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
    CountDown()
}
