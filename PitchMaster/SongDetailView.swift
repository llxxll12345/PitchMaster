//
//  SongDetailView.swift
//  Time
//
//  Created by Lixing Liu on 12/17/23.
//

import Foundation
import SwiftUI

struct SongDetailView: View {
    var song: Song
    @State var notes: [Note] = []
    @EnvironmentObject private var settings: Settings

    var body: some View {
        VStack {
            HStack {
                Text("Name: \(song.name ?? "")")
                Text("Duration: \(String(format: "%.2f", song.duration))")
                Text("Default BPM: \(String(format: "%.2f", song.defaultBPM))")
            }
            HStack {
                Text("Highest Pitch: \(String(format: "%d", song.highestPitch))")
                Text("Lowest Pitch: \(String(format: "%d", song.lowestPitch))")
                Text("Best score: \(String(format: "%.1f", song.bestScore))")
            }
            
            List {
                ForEach(notes, id: \.self) { note in
                    HStack {
                        NoteDetailView(note: note)
                    }
                }
            }
            
        }.onAppear() {
            notes = decodeJsonString(jsonString: song.notes ?? "")
        }.navigationTitle("Song Details")
            .navigationBarItems(trailing:
                NavigationLink(destination: PracticeView(expectedNotes: notes, song: song).environmentObject(settings)) {
                    Text("Go Practice!").font(.headline)
                }
            )
    }
}
