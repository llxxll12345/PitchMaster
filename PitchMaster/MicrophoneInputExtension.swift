/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The AudioSpectrogram extension for AVFoundation support.
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
        /// reproduce and is half the sampling rate of such a system. Although  this app doesn't use
        /// `nyquistFrequency`,  you may find this code useful to add an overlay to the user interface.
        if nyquistFrequency == nil {
            let duration = Float(CMSampleBufferGetDuration(sampleBuffer).value)
            let timescale = Float(CMSampleBufferGetDuration(sampleBuffer).timescale)
            let numsamples = Float(CMSampleBufferGetNumSamples(sampleBuffer))
            nyquistFrequency = 0.5 / (duration / timescale / numsamples)
        }
        
        /// Because the audio spectrogram code requires exactly `sampleCount` (which the app defines
        /// as 1024) samples, but audio sample buffers from AVFoundation may not always contain exactly
        /// 1024 samples, the app adds the contents of each audio sample buffer to `rawAudioData`.
        ///
        /// The following code creates an array from `data` and appends it to  `rawAudioData`:
        if self.rawAudioData.count < MicrophoneInput.sampleCount * 2 {
            let actualSampleCount = CMSampleBufferGetNumSamples(sampleBuffer)
            
            let pointer = data.bindMemory(to: Int16.self,
                                          capacity: actualSampleCount)
            let buffer = UnsafeBufferPointer(start: pointer,
                                             count: actualSampleCount)
            
            rawAudioData.append(contentsOf: Array(buffer))
        }

        /// The following code app passes the first `sampleCount`elements of raw audio data to the
        /// `processData(values:)` function, and removes the first `hopCount` elements from
        /// `rawAudioData`.
        ///
        /// By removing fewer elements than each step processes, the rendered frames of data overlap,
        /// ensuring no loss of audio data.
        while self.rawAudioData.count >= MicrophoneInput.sampleCount {
            let dataToProcess = Array(self.rawAudioData[0 ..< MicrophoneInput.sampleCount])
            self.rawAudioData.removeFirst(MicrophoneInput.hopCount)
            self.processData(values: dataToProcess)
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
    
    func startRunning() {
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