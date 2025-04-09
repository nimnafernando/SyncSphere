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
        
        VStack(){
            
            Text("Profile")
                .font(.title)
                .bold()
                .padding(.top, 20)
            
            BorderedText(text: user.username, placeholder: "User Name :")
            BorderedText(text: user.email, placeholder: "User Email :")
            BorderedText(text: DateFormatExtension.formatDate(from: user.createdAt), placeholder: "Created At :")
       
            AuthButton(label:"Forgot Password", width: 0.9) {
                
            }
            
            Spacer()
            
        }.frame(width: UIScreen.main.bounds.width * 0.98, alignment: .leading)
        
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
