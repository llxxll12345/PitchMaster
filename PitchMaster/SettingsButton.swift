//
//  SettingsButton.swift
//  PitchMaster
//
//  Created by Lixing Liu on 1/7/24.
//

import SwiftUI
import Foundation

struct SettingsButton: View {
    @Binding var settingsButtonTapped: Bool
    var body: some View {
        Button(action: {
            settingsButtonTapped = true
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }.sheet(isPresented: $settingsButtonTapped, content: {
            SettingsView()
        })
    }
}
