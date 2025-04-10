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
                    .position(x: 200, y: 250)
                
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
                    .position(x: 30, y: 560)
                
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
                    .frame(width: 500, height: 530)
                    .position(x: 320, y: 600)
                
                VStack(spacing: -40) {
                  
                    Rectangle()
                        .fill(Color.OffWhite)
                        .cornerRadius(40)
                        .frame(height: UIScreen.main.bounds.height * 0.51)
                        .overlay(
                            GeometryReader { geo in
                                VStack(alignment: .leading) {
                                 
                                    Text("Coming Up")
                                        .font(.title3)
                                        .padding(.leading, 16)
                                    
                                    Text("My Birthday")
                                        .font(.largeTitle)
                                        .bold()
                                        .padding(.leading, 16)
                                    
                                    HStack {
                                        Spacer()
                                        CountDown()
                                        Spacer()
                                    }
                                    
                                    CustomProgressBar()
                                        .padding(.top, 6)
                                }
                                .padding(.top, UIScreen.main.bounds.height * 0.13)
                                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea()

                    VStack(alignment: .leading) {
                        Text("Event Categories")
                            .font(.title3)
                        
                        TaskCard(
                            icon: "wrench.adjustable",
                            iconColor: .Lavendar,
                            title: "In Progress",
                            subtitle: "Finished Events",
                            count: 08
                        )
                        TaskCard(
                            icon: "calendar",
                            iconColor: .CustomPink,
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
                    Spacer()
                    
                    HStack{
                         Spacer()
                        NavigationLink(destination: AllEventsView()) {
                            Image(systemName: "plus")
                                .font(.system(size: 28))
                                .foregroundColor(Color.white)
                                .padding(20)
                                .background(
                                    Circle()
                                        .fill(Color.Lavendar)
                                )
                                .padding(.trailing, 20)
                        }

                    }
                }
                
                // Sidebar button at top-right
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            isSidebarVisible.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 22))
                            .foregroundColor(Color.black)
                        }.padding(.leading, 18)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            isSidebarVisible.toggle()
                        }
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 22))
                            .foregroundColor(Color.Lavendar)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.Lavendar.opacity(0.3))
                            ).padding(.trailing, 16)
                           
                    }
                    
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
                SideBarView(isVisible: $isSidebarVisible, navigateToSignIn: $navigateToSignIn)
                                    .environmentObject(profileViewModel)
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
