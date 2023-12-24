//
//  PersistenceController.swift
//  Time
//
//  Created by Lixing Liu on 12/15/23.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        for _ in 0..<10 {
            let song = Song(context: controller.container.viewContext)
            song.name = "song"
            song.duration = 10.0
        }

        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PitchMaster")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
