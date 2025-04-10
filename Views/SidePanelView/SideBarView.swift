//
//  SideBarView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-10.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @Binding var isVisible: Bool
    @Binding var navigateToSignIn: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if let user = profileViewModel.user {
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            Text("Welcome,")
                                .font(.title3)
                            Text(user.username)
                                .font(.title2)
                                .bold()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isVisible = false
                            }
                        }) {
                            Image(systemName: "x.circle")
                                .font(.title3)
                                .foregroundColor(.black)
                                .padding(.top, -20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 80)
                    .padding(.bottom, 40)
                }
 
                // Sidebar menu items
                VStack(spacing: 40) {
                    NavigationLink(destination: ProfileView()) {
                        HStack {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    NavigationLink(destination: TaskCategoryView()) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Task Category")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    NavigationLink(destination: WeatherForcastView()) {
                        HStack {
                            Image(systemName: "sun.max")
                            Text("Weather Forcast")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    NavigationLink(destination: HelpView()) {
                        HStack {
                            Image(systemName: "questionmark")
                            Text("Help")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        profileViewModel.signOut()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            navigateToSignIn = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.forward.circle.fill")
                            Text("Sign Out")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 30)
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)
                .foregroundColor(.black)
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * 0.75)
            .background(Color.OffWhite)
            .offset(x: isVisible ? 0 : -UIScreen.main.bounds.width * 0.75)
            
            Spacer()
        }
        .animation(.spring(), value: isVisible)
        .ignoresSafeArea()
    }
}
