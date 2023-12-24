//
//  Settings.swift
//  PitchMaster
//
//  Created by Lixing Liu on 12/21/23.
//

import Foundation


class Settings: ObservableObject {
    @Published var showNoteNames: Bool {
        didSet {
            UserDefaults.standard.set(showNoteNames, forKey: "showNoteNames")
        }
    }

    @Published var inputVolumeThreshold: Int {
        didSet {
            UserDefaults.standard.set(inputVolumeThreshold, forKey: "inputVolumeThreshold")
        }
    }

    init() {
        UserDefaults.standard.register(defaults: [
            "showNoteNames": true,
            "inputVolumeThreshold": 20,
        ])
        self.showNoteNames = UserDefaults.standard.bool(forKey: "showNoteNames")
        self.inputVolumeThreshold = UserDefaults.standard.integer(forKey: "inputVolumeThreshold")
    }
}
