//
//  NotificationView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct NotificationView: View {
    @StateObject private var viewModel = NotificationViewModel()
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notifications")
                    .font(.largeTitle).bold()
                Spacer()
            }
            .padding([.top, .horizontal])
            
            if viewModel.isLoading {
                Spacer()
                VStack {
                    ProgressView()
                    Text("Loading notifications...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                Spacer()
            } else if viewModel.notifications.isEmpty {
                Spacer()
                VStack(spacing: 24) {
                    Image(systemName: "clipboard")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.purple)
                        .overlay(
                            Text("z\nz")
                                .font(.title)
                                .foregroundColor(.blue)
                                .offset(x: 36, y: -32)
                        )
                    Text("No Notifications Here.")
                        .font(.title2).bold()
                        .padding(.top, 8)
                    Text("There are no notifications to display at the moment. Please check back later.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 32)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.notifications) { notification in
                            HStack(alignment: .top, spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.purple.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 22))
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.taskName)
                                        .font(.headline)
                                    Text(formattedDueDate(notification.dueDate))
                                        .font(.subheadline)
                                        .foregroundColor(colorForDueDate(notification.dueDate))
                                    Text(notification.eventName)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            )
                            .padding(.horizontal, 18)
                        }
                    }
                    .padding(.top, 12)
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.07), Color.yellow.opacity(0.07)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .onAppear {
            if let userId = profileViewModel.user?.id {
                viewModel.fetchNotifications(for: userId)
            }
        }
    }
    
    private func formattedDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Due " + formatter.string(from: date)
    }
    
    private func colorForDueDate(_ date: Date) -> Color {
        if Calendar.current.isDateInToday(date) {
            return .blue
        } else if date < Date() {
            return .red
        } else {
            return .gray
        }
    }
}

#Preview {
    NotificationView().environmentObject(ProfileViewModel())
}

