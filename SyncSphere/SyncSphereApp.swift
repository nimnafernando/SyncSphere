//
//  SyncSphereApp.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-03-29.
//

import SwiftUI
import FirebaseCore

@main
struct SyncSphereApp: App {
    @StateObject var profileViewModel = ProfileViewModel()
    let persistenceController = PersistenceController.shared
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(profileViewModel)
        }
    }
}
