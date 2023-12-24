//
//  FrequencyVisualizer.swift
//  Time
//
//  Created by Lixing Liu on 12/11/23.
//

import SwiftUI

struct PracticeVisualizer: View {
    var lowestPitch: Int
    var highestPitch: Int
    @ObservedObject var practiceManager: PracticeManager
    @Binding var showNotes: Bool
    
    let KEY_WIDTH: CGFloat = 70
    let PADDING: CGFloat = 10
    var range: Int {
        highestPitch - lowestPitch
    }
    
    var body: some View {
        GeometryReader {geometry in
            ScrollView {
                VStack {
                    Canvas { context, size in
                        let rectWidth: CGFloat = (size.width - KEY_WIDTH) / CGFloat(practiceManager.displayedNotes.count)
                        let rectHeight: CGFloat = (size.height - PADDING * 2) / CGFloat(range)
                        var xPosition: CGFloat = KEY_WIDTH
                        
                        for value in lowestPitch..<(lowestPitch + range) {
                            let noteName = midiToNoteName(value)
                            let isHalfNote = noteName.contains("#")
                            let height = (1 - CGFloat(value - lowestPitch) / CGFloat(range)) * (size.height - PADDING * 2) + PADDING
                            let rect = CGRect(x: 0, y: height - rectHeight, width: KEY_WIDTH, height: rectHeight)
                            context.stroke(Path(rect), with: .color(.black), lineWidth: 2)
                            let isInputNote = value == practiceManager.noteNumber
                            context.fill(Path(rect), with: .color(!isInputNote ? (isHalfNote ? .black : .white) : .yellow))
                            if showNotes {
                                context.draw(Text(noteName).bold().font(.system(size: 15)).foregroundColor(isHalfNote ? .white : .black), at: CGPoint(x: 15, y: height - 15))
                            }
                        }
                        
                        for value in practiceManager.displayedNotes {
                            let height = (1 - CGFloat(value - lowestPitch) / CGFloat(range)) * (size.height - PADDING * 2) + PADDING
                            if height < 0 || height > size.height {
                                xPosition += rectWidth
                                continue
                            }
                            let rect = CGRect(x: xPosition, y: height - rectHeight, width: rectWidth, height: rectHeight)
                            context.fill(Path(rect), with: .color(.blue))
                            
                            xPosition += rectWidth
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
}
