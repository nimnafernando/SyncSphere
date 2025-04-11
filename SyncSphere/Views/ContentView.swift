//
//  ContentView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-03-29.
//

import SwiftUI
import CoreData
import FirebaseCore

struct ContentView: View {
    
    @State private var mainViewModel = MainViewModel()
    @State private var isLoading = true
    
    var body: some View {
           ZStack {
               if isLoading {
                   ProgressView()
               } else if mainViewModel.isSignin, !mainViewModel.userId.isEmpty {
                   DashboardView()
                       .environmentObject(mainViewModel.profileViewModel) 
               } else {
                   SignInView()
               }
           }
           .onAppear {
              
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                   isLoading = false
               }
           }
       }
   }

#Preview {
    ContentView()
}
