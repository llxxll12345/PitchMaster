//
//  FreeSing.swift
//  Time
//
//  Created by Lixing Liu on 12/17/23.
//

import SwiftUI

struct FreeSingView: View {
    @StateObject private var freeSingManager = FreeSingManager()
    @State var startNote : Int = 40
    @State var octaves : Int = 2
    @EnvironmentObject private var settings: Settings
    @State private var settingsButtonTapped: Bool = false

    var body: some View {
        VStack() {
            HStack{
                if freeSingManager.tickerLeft {
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
                
                Text("Select You BPM")
                    .padding()
                Picker("Select BPM", selection: $freeSingManager.speed) {
                    ForEach(40..<180,  id: \.self) { index in
                        Text("\(index)")
                            .tag(index)
                    }
                }.disabled(freeSingManager.isRunning)
                .padding()
                Text("Select Vocal Range")
                Picker("Select Start Note", selection: $startNote) {
                    ForEach(24..<112, id: \.self) { index in
                        Text("\(midiToNoteName(index))")
                            .tag(index)
                    }
                }.disabled(freeSingManager.isRunning)
                .padding()
                Picker("Select Octaves", selection: $octaves) {
                    ForEach(1..<4) { index in
                        Text("\(index)")
                            .tag(index)
                    }
                }
                .disabled(freeSingManager.isRunning)
                .padding()
                Toggle(isOn: $freeSingManager.saveRecording) {
                    Text("Save recording")
                }
                .padding()
                SettingsButton(settingsButtonTapped: $settingsButtonTapped)
            }
            HStack {
                Text("Time: \(String(format: "%.2f", freeSingManager.timeElapsed)) seconds")
                    .font(.headline)
                    .padding()
                Text("Note: \(freeSingManager.noteName)")
                    .font(.headline)
                    .padding()
                Text("Freq: \(String(format: "%.2f", freeSingManager.loudestFrequency)) Hz")
                    .font(.headline)
                    .padding()
            }
            FreeSingVisualizer(lowestPitch: $startNote, octaves: $octaves, showNotes: $settings.showNoteNames, freeSingManager: freeSingManager)
            
            HStack {
                if !freeSingManager.isRunning {
                    Button(action: {
                        self.freeSingManager.startTimer()
                    }) {
                        Image(systemName: "play")
                    }.frame(width: 50, height: 50).padding()
                } else {
                    Button(action: {
                        self.freeSingManager.pauseTime()
                    }) {
                        Image(systemName: "pause")
                    }
                    .frame(width: 50, height: 50).padding()
                }
                
                Button(action: {
                    self.freeSingManager.resetTimer()
                }) {
                    Image(systemName: "stop")
                }
                .frame(width: 50, height: 50).padding()
            }
        }.alert(isPresented: $freeSingManager.showAlert) {
            Alert(
                title: Text("Data limit"),
                message: Text("You have reached voice recording limit. Old data will be dropped"),
                dismissButton: .default(Text("OK")) {
                    freeSingManager.showAlert = false
               }
            )
        }.sheet(isPresented: $freeSingManager.saveToFile) {
            SaveRecordingView(manager: freeSingManager)
        }
    }
}


struct FreeSingView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Settings())
    }
}
