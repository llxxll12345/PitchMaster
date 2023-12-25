//
//  NoteDetailView.swift
//  PitchMaster
//
//  Created by Lixing Liu on 12/24/23.
//

import SwiftUI

struct NoteDetailView: View {
    var note: Note
    var body: some View {
        if note.id == 0 {
            Text("Rest")
        } else {
            Text("Note: \(midiToNoteName(_:note.id))")
        }
        Text("Start: \(String(format: "%.2f", note.start))")
        Text("Duration: \(String(format: "%.2f", note.duration))")
    }
}
