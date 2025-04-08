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
    
    @State private var mainVIewModel = MainViewModel()
    
    var body: some View {
        
        if mainVIewModel.isSignin, !mainVIewModel.userId.isEmpty {
            DashboardView()
        } else {
            SignInView()
        }
    }
    
}

// apple call back https://syncsphere-app.firebaseapp.com/__/auth/handler

#Preview {
    ContentView()
}
