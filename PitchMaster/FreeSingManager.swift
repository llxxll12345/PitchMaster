//
//  Timer.swift
//  Time
//
//  Created by Lixing Liu on 12/6/23.
//

import SwiftUI
import Combine

class FreeSingManager: NoteDisplayStateManager {
    @Published var timeStampSelection: Int = 0
    
    let MAX_COUNT = 10000
    @Published var showAlert = false
    @Published var alertShown = false
    
    var pastNotes = [Int]()
    
    override func updateNoteRecord() {
        if self.pastNotes.count == self.MAX_COUNT {
            self.pastNotes.remove(at: 0)
            if !self.alertShown {
                self.showAlert = true
                self.alertShown = true
            }
        }
        self.pastNotes.append(self.noteNumber)
        self.timeStampSelection = self.pastNotes.count - 1
    }
    
    override func updateDisplayedNotes() {
        self.displayedNotes.remove(at: self.displayedNotes.count - 1)
        self.displayedNotes.insert(self.noteNumber, at: 0)
    }
}

