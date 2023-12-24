//
//  AddSong.swift
//  Time
//
//  Created by Lixing Liu on 12/10/23.
//

import SwiftUI

struct AddSongView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @State var songName: String = ""
    @State var duration: Float = 0.0
    @State var defaultBPM: Int = 0
    @State var BPMInput: String = ""
    @State var notes: [Note] = []
    @State var lowestPitch: Int = 60
    @State var octaves: Int = 2

    var body: some View {
        NavigationView {
            Form {
                TextField("Song Name", text: $songName)
               
                TextField("Default BPM (beats)", text: $BPMInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad) // Set the keyboard type to decimal pad for numeric input
                    .onChange(of: BPMInput) {
                        defaultBPM = convertToInt(stringInput: BPMInput)
                    }
                Picker("Lowest pitch:", selection: $lowestPitch) {
                    ForEach(24..<112) { index in
                        Text("\(midiToNoteName(index))")
                            .tag(index)
                    }
                }
                .padding()
                Picker("Octaves:", selection: $octaves) {
                    ForEach(1..<4) { index in
                        Text("\(index)")
                            .tag(index)
                    }
                }
                .padding()
                NavigationLink(destination: AddNotesView(notes: $notes, songDuration: $duration, lowestPitch: lowestPitch, octaves: octaves)) {
                    Text("notes")
                }
                Button("Add Song") {
                    addSong()
                    isPresented = false
                }
            }
        }
        .navigationTitle("Add Song")
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(trailing:
            Button("Cancel") {
                isPresented = false
            }
        )
    }

    private func addSong() {
        let newSong = Song(context: viewContext)
        newSong.name = songName
        newSong.duration = duration
        newSong.defaultBPM = Int64(defaultBPM)
        newSong.id = UUID()
        newSong.notes = encodeJsonString(notes: notes)
        newSong.lowestPitch = Int64(lowestPitch)
        newSong.highestPitch = Int64(lowestPitch + octaves * 12)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
