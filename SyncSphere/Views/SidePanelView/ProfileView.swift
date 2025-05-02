//
//  ProfileViewView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-08.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    var body: some View {
        if let syncUser = profileViewModel.user {
            ProfileView(user: syncUser)
        } else {
            ProgressView()
                .onAppear {
                profileViewModel.fetchUser()
                }
        }
    }
    
    @ViewBuilder
    func ProfileView(user: SyncUser) -> some View {
        
        NavigationStack{
            ZStack{
                GradientBackground()
                
                VStack(){
                    if let user = profileViewModel.user {
                        
                        VStack(alignment: .leading) {
                            Text("Welcome,")
                                .font(.headline)
                                .padding(.bottom, 1)
                            Text(user.username)
                                .font(.title)
                                .bold()
                        }
                        .frame(width: UIScreen.main.bounds.width*0.9, alignment: .leading)
                        .padding(.bottom, 20)
                    }
                    
                    VStack {
                        BorderedText(text: user.username, placeholder: "User Name", iconName: "pencil", frontImage: "person", color: .blue)
                            .padding(.top, 20)
                        BorderedText(text: user.email, placeholder: "User Email", frontImage: "at")
                        BorderedText(text: DateFormatExtension.formatDate(from: user.createdAt), placeholder: "Created At", frontImage: "calendar")
                            .padding(.bottom, 20)
                    }
                    .background(Color.OffWhite)
                    .cornerRadius(20)
                    .padding(.horizontal, 8)
                    
                    Spacer()
                    
                    NavigationLink(destination: ForgotPasswordView()){
                        Text("Forgot Password")
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.98, alignment: .leading)
                
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
    return ProfileView()
            .environmentObject(mockViewModel)
}
