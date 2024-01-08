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
                Text("Speed x\(String(format: "%.1f", practiceManager.playbackSpeed))")
                Slider(
                   value: $practiceManager.playbackSpeed,
                   in: 0.1...5.0,
                   step: 0.1,
                   minimumValueLabel: Text("0.1"),
                   maximumValueLabel: Text("5.0")
                ) {
                   Text("Playback speed")
                }
                .disabled(practiceManager.isRunning)
                .padding()
                Spacer()
                Toggle(isOn: $practiceManager.saveRecording) {
                    Text("Save recording")
                }
                .padding()
                SettingsButton(settingsButtonTapped: $settingsButtonTapped)
            }
            HStack {
                Text("Time: \(String(format: "%.2f", practiceManager.timeElapsed)) seconds")
                    .font(.headline)
                    .padding()
                Text("You sang: \(practiceManager.noteName)")
                    .font(.headline)
                    .padding()
                Text("Expected: \(practiceManager.expectedNoteName)")
                    .font(.headline)
                    .padding()
                Text("Score: \(String(format: "%.1f", practiceManager.score))/100")
                    .font(.headline)
                    .padding()
            }
            PracticeVisualizer(lowestPitch: Int(song.lowestPitch), highestPitch: Int(song.highestPitch), practiceManager: self.practiceManager, showNotes: $settings.showNoteNames)
           
            HStack {
                if !practiceManager.isRunning {
                    Button(action: {
                        self.practiceManager.startTimer()
                    }) {
                        Image(systemName: "play")
                    }.frame(width: 50, height: 50).padding()
                } else {
                    Button(action: {
                        self.practiceManager.pauseTime()
                    }) {
                        Image(systemName: "pause")
                    }
                    .frame(width: 50, height: 50).padding()
                }
                
                Button(action: {
                    self.practiceManager.resetTimer()
                }) {
                    Image(systemName: "stop")
                }
                .frame(width: 50, height: 50).padding()
            }
        }.onAppear {
            practiceManager.duration = Float(song.duration)
            practiceManager.expectedNotes = expectedNotes
            practiceManager.defaultBPM = Int(song.defaultBPM)
        }.onDisappear() {
            saveScore()
        }.sheet(isPresented: $practiceManager.saveToFile) {
            SaveRecordingView(manager: practiceManager)
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
