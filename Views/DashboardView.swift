//
//  DashboardView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-08.
//

import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @State private var isSidebarVisible = false
    @State private var userName: String?
    @State private var navigateToSignIn = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                
                // Gradient Circle 1
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.CustomPink.opacity(0.5), Color.clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                    )
                    .frame(width: 500, height: 500)
                    .position(x: 200, y: 200)
                
                // Gradient Circle 2
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.Lavendar.opacity(0.3), Color.clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 450, height: 450)
                    .position(x: 30, y: 500)
                
                // Gradient Circle 3
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.SystemBeige, Color.clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                    )
                    .frame(width: 500, height: 500)
                    .position(x: 320, y: 600)
                
                VStack {
                  
                    Rectangle()
                        .fill(Color.OffWhite)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(40)
                        .frame(height: UIScreen.main.bounds.height * 0.52)
                        .overlay(
                            GeometryReader { geo in
                                VStack(alignment: .leading) {
                                    Text("Coming Up")
                                        .font(.title3)
                                        .padding(.top, 16)
                                        .padding(.leading, 16)
                                    
                                    Text("My Birthday")
                                        .font(.largeTitle)
                                        .bold()
                                        .padding(.leading, 16)
                                    
                                    CountDown()
                                        .padding(.leading, 16)
                                    
                                    CustomProgressBar()
                                        .padding(.top, 20)
                                }
                                .padding(.top, UIScreen.main.bounds.height * 0.08)
                                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea()

                    VStack {
                        TaskCard(
                            icon: "paintbrush.pointed",
                            iconColor: .blue,
                            title: "In Progress",
                            subtitle: "Finished Events",
                            count: 08
                        )
                        TaskCard(
                            icon: "wand.and.sparkles.inverse",
                            iconColor: .orange,
                            title: "Up Coming",
                            subtitle: "Finished Events",
                            count: 05
                        )
                        TaskCard(
                            icon: "checkmark.rectangle.stack",
                            iconColor: .green,
                            title: "Completed",
                            subtitle: "Finished Events",
                            count: 12
                        )
                        
                    }
                    
                }
                
                // Sidebar button at top-right
                Button(action: {
                    withAnimation(.spring()) {
                        isSidebarVisible.toggle()
                    }
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                        )
                        .padding()
                }
                
                
                // Overlay for sidebar background
                if isSidebarVisible {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isSidebarVisible = false
                            }
                        }
                }
                
                // Sidebar panel
                HStack(spacing: 0) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack {
                            Text("Settings")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    isSidebarVisible = false
                                }
                            }) {
                                Image(systemName: "x.circle")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .padding(.top, 80)
                        
                        // Sidebar menu items
                        Button(action: {}) {
                            
                            VStack(spacing: 40){
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
                            .padding(.top, 30)
                            
                        }
                        .foregroundColor(.black)
                        .padding()
                        
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.75)
                    .background(Color.white)
                    .offset(x: isSidebarVisible ? 0 : -UIScreen.main.bounds.width * 0.75)
                    
                    Spacer()
                }
                .animation(.spring(), value: isSidebarVisible)
                .ignoresSafeArea()
            }
            .frame(maxWidth: .infinity)
            .navigationDestination(isPresented: $navigateToSignIn) {
                SignInView()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    let previewProfileVM = ProfileViewModel()
    previewProfileVM.user = SyncUser(id: "preview", username: "User", email: "test@example.com", createdAt: Date().timeIntervalSince1970)
    
    return DashboardView()
        .environmentObject(previewProfileVM)
}
