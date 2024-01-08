/*
Moified from code in this example:
https://developer.apple.com/documentation/accelerate/visualizing_sound_as_an_audio_spectrogram

This file defines the microphone input handling class extension to implement functions the 
 AVCaptureAudioDataOutputSampleBufferDelegate protocol. 
*/

import AVFoundation

extension MicrophoneInput: AVCaptureAudioDataOutputSampleBufferDelegate {
 
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {

        var audioBufferList = AudioBufferList()
        var blockBuffer: CMBlockBuffer?
  
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout.stride(ofValue: audioBufferList),
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: &blockBuffer)
        
        guard let data = audioBufferList.mBuffers.mData else {
            return
        }
        
        /// The _Nyquist frequency_ is the highest frequency that a sampled system can properly
        /// reproduce and is half the sampling rate of such a system.
        if nyquistFrequency == nil {
            let duration = Float(CMSampleBufferGetDuration(sampleBuffer).value)
            let timescale = Float(CMSampleBufferGetDuration(sampleBuffer).timescale)
            let numsamples = Float(CMSampleBufferGetNumSamples(sampleBuffer))
            nyquistFrequency = 0.5 / (duration / timescale / numsamples)
        }
        
        /// The size of the sampleBuffer isn't always sampleCount so we append until
        ///  we get enough data.
        if self.rawAudioData.count < MicrophoneInput.sampleCount * 2 {
            let actualSampleCount = CMSampleBufferGetNumSamples(sampleBuffer)
            
            // data is an unsafe raw pointer and we are accessing
            // it as an Int16 array with actualSampleCount elements.
            let pointer = data.bindMemory(to: Int16.self,
                                          capacity: actualSampleCount)
            let buffer = UnsafeBufferPointer(start: pointer,
                                             count: actualSampleCount)
            
            rawAudioData.append(contentsOf: Array(buffer))
        }

        /// Move the sliding window of size sampleCount on rawAudioData forward by hopCount
        ///  when we have enough data.
        while self.rawAudioData.count >= MicrophoneInput.sampleCount {
            let dataToProcess = Array(self.rawAudioData[0 ..< MicrophoneInput.sampleCount])
            self.rawAudioData.removeFirst(MicrophoneInput.hopCount)
            self.processData(values: dataToProcess)
        }
        
        if self.saveRecording {
            if let pcmData = convertToPCMData(sampleBuffer: sampleBuffer) {
                accumulatedData.append(pcmData)
            }
        }
    }
    
    func configureCaptureSession() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized:
                    break
            case .notDetermined:
                sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .audio,
                                              completionHandler: { granted in
                    if !granted {
                        fatalError("App requires microphone access.")
                    } else {
                        self.configureCaptureSession()
                        self.sessionQueue.resume()
                    }
                })
                return
            default:
                // Users can add authorization by choosing Settings > Privacy >
                // Microphone on an iOS device, or System Preferences >
                // Security & Privacy > Microphone on a macOS device.
                fatalError("App requires microphone access.")
        }
        
        captureSession.beginConfiguration()
        
        if captureSession.canAddOutput(audioOutput) {
            captureSession.addOutput(audioOutput)
        } else {
            fatalError("Can't add `audioOutput`.")
        }

        guard
            let microphone = AVCaptureDevice.default(AVCaptureDevice.DeviceType.microphone,
                                                     for: .audio,
                                                     position: .unspecified),
            let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
                fatalError("Can't create microphone.")
        }
        
        if captureSession.canAddInput(microphoneInput) {
            captureSession.addInput(microphoneInput)
        }

        captureSession.commitConfiguration()
    }
    
    func startRunning(saveRecording: Bool) {
        sessionQueue.async {
            if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopRunning() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}
