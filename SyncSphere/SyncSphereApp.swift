//
//  SyncSphereApp.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-03-29.
//

import SwiftUI

@main
struct SyncSphereApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
