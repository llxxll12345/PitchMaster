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
                settingsButton
            }
            
            FreeSingVisualizer(lowestPitch: $startNote, octaves: $octaves, showNotes: $settings.showNoteNames, freeSingManager: freeSingManager)
            HStack {
                Text("Time passed: \(String(format: "%.2f", freeSingManager.timeElapsed)) seconds")
                    .font(.headline)
                    .padding()
                Text("Freq: \(String(format: "%.2f", freeSingManager.loudestFrequency)) Hz")
                    .font(.headline)
                    .padding()
            }
            HStack {
                Text("Note: \(freeSingManager.noteName)")
                    .font(.headline)
                    .padding()
            }
            HStack {
                Button(action: {
                    self.freeSingManager.startTimer()
                }) {
                    Text("Start")
                }
                .padding()
                Button(action: {
                    self.freeSingManager.pauseTime()
                }) {
                    Text("Pause")
                }
                .padding()
                Button(action: {
                    self.freeSingManager.resetTimer()
                }) {
                    Text("Reset")
                }
                .padding()
            }
        }.alert(isPresented: $freeSingManager.showAlert) {
            Alert(
                title: Text("Data limit"),
                message: Text("You have reached voice recording limit. Old data will be dropped"),
                dismissButton: .default(Text("OK")) {
                    freeSingManager.showAlert = false
               }
            )
        }.sheet(isPresented: $settingsButtonTapped, content: {
            SettingsView()
        })
    }
}


struct FreeSingView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
