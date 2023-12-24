//
//  NoteDisplayStateManager.swift
//  Time
//
//  Created by Lixing Liu on 12/18/23.
//

import Foundation
import SwiftUI
import Combine

class NoteDisplayStateManager: ObservableObject {
    static let WINDOW_SIZE = 100
    static let BUFFER_TIME : Float = 2.0
    
    @Published var timeElapsed : Float = 0.0
    @Published var isRunning = false
    @Published var speed = 60
    @Published var tickerLeft = true
    @Published var loudestFrequency: Float = 0
    @Published var noteNumber = 0
    @Published var noteName: String = ""
    @Published var displayedNotes = [Int](repeating: 0, count: WINDOW_SIZE)
    
    let microphoneInput = MicrophoneInput()
    
    
    var beats: Int {
        return Int(timeElapsed/(60.0/Float(speed)))
    }
    
    var timer = Timer()
    func startTimer() {
        if !isRunning {
            self.microphoneInput.startRunning()
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                self.timeElapsed += 0.01
                if (self.beats % 2 == 0) {
                    self.tickerLeft = true
                } else {
                    self.tickerLeft = false
                }
                // Refresh rate: 50 fps
                if Int(self.timeElapsed * 100) % 2 == 0 {
                    self.loudestFrequency = self.microphoneInput.loudestFrequency
                    self.noteNumber = frequencyToMIDI(self.loudestFrequency)
                    self.noteName = midiToNoteName(self.noteNumber)
                    
                    self.updateDisplayedNotes()
                    self.updateNoteRecord()
                }
                if self.finishedAllNotes() {
                    self.resetTimer()
                }
            }
            isRunning = true
        }
    }
    
    func finishedAllNotes() -> Bool {
        return false
    }
    
    func updateNoteRecord() {
    }
    
    func updateDisplayedNotes() {
    }
    
    func pauseTime() {
        timer.invalidate()
        isRunning = false
        self.microphoneInput.stopRunning()
        self.loudestFrequency = 0
        
    }
    
    func resetTimer() {
        timer.invalidate()
        isRunning = false
        self.timeElapsed = 0
        self.tickerLeft = true
        self.microphoneInput.stopRunning()
        self.loudestFrequency = 0
        self.displayedNotes = [Int](repeating: 0, count: PracticeManager.WINDOW_SIZE)
    }
}
