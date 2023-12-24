//
//  SettingsView.swift
//  PitchMaster
//
//  Created by Lixing Liu on 12/21/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: Settings
    @State private var inputVolumeThreshold: Double = 0.0

    var body: some View {
        VStack {
            Toggle("Show note names", isOn: $settings.showNoteNames)
                .padding()
            Text("Input volume threshold: ")
            Slider(value: $inputVolumeThreshold, in: 0...100, step: 1.0)
                .onChange(of: inputVolumeThreshold) {
                    settings.inputVolumeThreshold = Int(inputVolumeThreshold)
                }
                .padding()
            Text("\(Int(inputVolumeThreshold))")
                .padding()
        }.onAppear {
            self.inputVolumeThreshold = Double(settings.inputVolumeThreshold)
        }
    }
}
