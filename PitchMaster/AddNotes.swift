//
//  AddNotes.swift
//  Time
//
//  Created by Lixing Liu on 12/16/23.
//

import Foundation
import SwiftUI

struct AddNotesView: View {
    @Binding var notes: [Note]
    @Binding var songDuration: Float
    var lowestPitch: Int
    var octaves: Int
    var defaultPitch: Int {
        return lowestPitch + 12
    }
    
    
    @State var noteID: Int = 60
    @State var noteDuration: Float = 1
    @State private var isRest = false
    
    let noteType: [String: Float] = ["Whole": 4, "Half": 2, "Quarter": 1, "Eighth": 0.5, "Sixteenth": 0.25]

    var body: some View {
        VStack {
            List {
                ForEach(notes.indices, id: \.self) { index in
                    NoteDetailView(note: notes[index])
                }
                .onDelete(perform: deleteItem)
            }
            HStack {
                Toggle(isOn: $isRest) {
                    Text("Resting Note")
                }
                .padding()
                Picker("Note Type:", selection: $noteDuration) {
                    ForEach(Array(noteType), id: \.key) { key, val in
                        Text("\(key)")
                            .tag(val)
                    }
                }
                .padding()
                
                if !isRest {
                    Picker("Note pitch:", selection: $noteID) {
                        ForEach(lowestPitch..<(lowestPitch+octaves*12)) { index in
                            Text("\(midiToNoteName(index))")
                                .tag(index)
                        }
                    }
                    .padding()
                }
            }
            Button("Add") {
                addItem()
            }
        }.onAppear {
            noteID = defaultPitch
        }
    }

    func addItem() {
        if isRest {
            noteID = 0
        }
        notes.append(Note(id: noteID, start: songDuration, duration: noteDuration))
        songDuration += noteDuration
        noteID = defaultPitch
        isRest = false
    }

    func deleteItem(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}
