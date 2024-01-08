//
//  util.swift
//  Time
//
//  Created by Lixing Liu on 12/15/23.
//

import Foundation
import SwiftUI

func frequencyToMIDI(_ frequency: Float) -> Int {
    if frequency < 1 {
        return 0
    }
    let midiNoteNumber = 69 + 12 * log2(frequency / 440.0)
    return Int(round(midiNoteNumber))
}

func midiToNoteName(_ midiNoteNumber: Int) -> String {
    if midiNoteNumber < 12 {
        return ""
    }
    let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    let noteIndex = (midiNoteNumber - 12) % 12
    let octave = (midiNoteNumber - 12) / 12
    
    return "\(noteNames[noteIndex])\(octave)"
}


func convertToFloat(stringInput: String) -> Float {
   if let convertedValue = Float(stringInput) {
       return convertedValue
   } else {
       return -1
   }
}

func convertToInt(stringInput: String) -> Int {
   if let convertedValue = Int(stringInput) {
       return convertedValue
   } else {
       return -1
   }
}


