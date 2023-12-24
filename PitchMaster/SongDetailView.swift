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
            NavigationLink(destination: PracticeView(expectedNotes: notes, song: song).environmentObject(settings)) {
                Text("Go Practice").font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            List {
                ForEach(notes, id: \.self) { note in
                    HStack {
                        Text("Note: \(midiToNoteName(_:note.id))")
                        Text("Start: \(String(format: "%.2f", note.start))")
                        Text("Duration: \(String(format: "%.2f", note.duration))")
                    }
                }
            }
            
        }.onAppear() {
            notes = decodeJsonString(jsonString: song.notes ?? "")
        }
    }
}
