//
//  PitchMasterApp.swift
//  PitchMaster
//
//  Created by Lixing Liu on 12/20/23.
//

import SwiftUI

@main
struct PitchMasterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(Settings())
        }
    }
}
