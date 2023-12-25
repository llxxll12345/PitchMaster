//
//  PracticeManager.swift
//  Time
//
//  Created by Lixing Liu on 12/15/23.
//

import Foundation

import SwiftUI
import Combine

class PracticeManager: NoteDisplayStateManager {
    var duration: Float = 0
    var expectedNotes: [Note] = []
    var defaultBPM: Int = 0
    var noteIndex = 0
    var expectedNoteName: String = "--"
    var score: Double = 0
    var scorableCount: Double = 0
    var playbackSpeed: Float {
        Float(speed)/Float(defaultBPM)
    }
    
    override func finishedAllNotes() -> Bool {
        return self.timeElapsed >= self.duration / self.playbackSpeed + PracticeManager.BUFFER_TIME
    }
    
    override func updateDisplayedNotes() {
        if self.expectedNotes.count == 0 {
            return
        }
        let currentNote = displayedNotes.remove(at: 0)
        if currentNote != 0 {
            self.expectedNoteName = midiToNoteName(currentNote)
            self.scorableCount += 1
            self.score = self.score * (1 - 1/self.scorableCount) + 1/Double(abs(self.noteNumber - currentNote) + 1) * 100/self.scorableCount
        }
        
        
        if noteIndex >= self.expectedNotes.count {
            displayedNotes.append(0)
            return
        }
        let noteEnd = (self.expectedNotes[noteIndex].start + self.expectedNotes[noteIndex].duration)/self.playbackSpeed
        if self.timeElapsed >= noteEnd {
            noteIndex += 1
        }
        if self.timeElapsed < noteEnd && self.timeElapsed >= self.expectedNotes[noteIndex].start / self.playbackSpeed {
            displayedNotes.append(self.expectedNotes[noteIndex].id)
            
        } else {
            displayedNotes.append(0)
        }
    }
    
    override func startTimer() {
        super.startTimer()
        self.score = 0
        self.scorableCount = 0
    }
    
    override func resetTimer() {
        super.resetTimer()
        self.noteIndex = 0
        self.scorableCount = 0
    }
}
