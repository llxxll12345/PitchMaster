//
//  MicrophoneInputAudioSaving.swift
//  PitchMaster
//
//  Created by Lixing Liu on 1/7/24.
//

import Foundation
import AudioToolbox
import AVFoundation

extension MicrophoneInput {
    func setupAudioConverter() {
        var audioStreamBasicDescription = AudioStreamBasicDescription(
            mSampleRate: 44100.0,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
            mBytesPerPacket: 2,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )

        var outputFormat = AudioStreamBasicDescription(
            mSampleRate: 44100.0,
            mFormatID: kAudioFormatMPEGLayer3,
            mFormatFlags: 0,
            mBytesPerPacket: 0,
            mFramesPerPacket: 1152,
            mBytesPerFrame: 0,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 0,
            mReserved: 0
        )

        AudioConverterNew(&audioStreamBasicDescription, &outputFormat, &audioConverter)
    }
    
    func convertToPCMData(sampleBuffer: CMSampleBuffer) -> Data? {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return nil }
        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
        
        guard let ptr = dataPointer else { return nil }
        let pcmData = Data(bytes: ptr, count: length)
        return pcmData
    }
    
    func saveToMP3File(filename: String) {
        guard let audioConverter = audioConverter else {
            print("Audio converter not set up.")
            return
        }
        
        let outputPath = URL(fileURLWithPath: "\(filename).mp3")
        do {
            try accumulatedData.write(to: outputPath)
            print("MP3 file saved at: \(outputPath)")
        } catch {
            print("Error saving MP3 file: \(error.localizedDescription)")
        }

        accumulatedData.removeAll()
    }
}
