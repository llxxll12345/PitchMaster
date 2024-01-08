//
//  SaveRecordingView.swift
//  PitchMaster
//
//  Created by Lixing Liu on 1/7/24.
//

import Foundation
import SwiftUI

struct SaveRecordingView: View {
    @ObservedObject var manager: NoteDisplayStateManager
    @State private var filename: String = ""
    var body: some View {
        VStack{
            TextField("File Name: ", text: $filename)
            Button(action: {
                manager.saveToFile = false
                manager.microphoneInput.saveToMP3File(filename: filename)
            }) {
                Text("Save")
            }
        }
    }
}
