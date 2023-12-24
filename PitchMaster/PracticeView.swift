//
//  PracticeView.swift
//  Time
//
//  Created by Lixing Liu on 12/15/23.
//

import SwiftUI
import CoreData

struct PracticeView: View {
    var expectedNotes : [Note]
    var song: Song
    
    @StateObject private var practiceManager = PracticeManager()
    @State private var settingsButtonTapped: Bool = false
    @EnvironmentObject private var settings: Settings
    @Environment(\.managedObjectContext) private var viewContext
    
    var settingsButton: some View {
        Button(action: {
            settingsButtonTapped = true
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
    
    var body: some View {
        VStack() {
            HStack{
                if practiceManager.tickerLeft {
                    Image("TickerLeft")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                } else {
                    Image("TickerRight")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
                Text("Default BPM: \(String(format: "%d", song.defaultBPM))")
                Text("Target BPM")
                    .padding().disabled(practiceManager.isRunning)
                Picker("Select BPM", selection: $practiceManager.speed) {
                    ForEach(40..<180) { index in
                        Text("\(index)")
                            .tag(index)
                    }
                }
                .padding()
                Spacer()
                settingsButton
            }
            
            PracticeVisualizer(lowestPitch: Int(song.lowestPitch), highestPitch: Int(song.highestPitch), practiceManager: self.practiceManager, showNotes: $settings.showNoteNames)
            HStack {
                Text("Time passed: \(String(format: "%.2f", practiceManager.timeElapsed)) seconds")
                    .font(.headline)
                    .padding()
                Text("You sang: \(practiceManager.noteName)")
                    .font(.headline)
                    .padding()
                Text("Expected: \(practiceManager.expectedNoteName)")
                    .font(.headline)
                    .padding()
                Text("\(practiceManager.noteName)")
                    .font(.headline)
                    .padding()
                Text("Score: \(String(format: "%.1f", practiceManager.score))")
                    .font(.headline)
                    .padding()
            }
            HStack {
                Button(action: {
                    self.practiceManager.startTimer()
                }) {
                    Text("Start")
                }
                .padding()
                Button(action: {
                    self.practiceManager.pauseTime()
                }) {
                    Text("Pause")
                }
                .padding()
                Button(action: {
                    self.practiceManager.resetTimer()
                }) {
                    Text("Reset")
                }
                .padding()
            }
        }.onAppear {
            practiceManager.duration = Float(song.duration)
            practiceManager.expectedNotes = expectedNotes
            practiceManager.defaultBPM = Int(song.defaultBPM)
        }.sheet(isPresented: $settingsButtonTapped, content: {
            SettingsView()
        }).onDisappear() {
            saveScore()
        }
    }
    
    func saveScore() {
        let fetchRequest: NSFetchRequest<Song> = Song.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", song.name ?? "")

        do {
            let objects = try viewContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                if objectToUpdate.bestScore < self.practiceManager.score {
                    objectToUpdate.bestScore = self.practiceManager.score
                    try? viewContext.save()
                }
            }
        } catch {
            // Handle fetch or save errors
            print("Error updating object: \(error)")
        }
    }
}


struct PracticeView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeView(expectedNotes: [Note(id: 50,  start: 1, duration: 1), Note(id: 52, start: 2, duration: 1), Note(id: 53,  start: 3, duration: 5)], song: Song())
    }
}
