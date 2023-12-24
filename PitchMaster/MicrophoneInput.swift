/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The class that provides a signal that represents a drum loop.
*/

import Accelerate
import Combine
import AVFoundation

class MicrophoneInput: NSObject {
    var zeroReference: Double = 10004
    var loudestFrequency: Float = 0
    var volumeThreshold: Float = 20
    
    override init() {
        super.init()
        
        configureCaptureSession()
        audioOutput.setSampleBufferDelegate(self,
                                            queue: captureQueue)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Frequency samples
    static let sampleCount = 8192
    /// Storing up to 100000 frequency data point.
    static let bufferCount = 10000
    
    
    /// Determines the overlap between frames.
    static let hopCount = 512

    let captureSession = AVCaptureSession()
    let audioOutput = AVCaptureAudioDataOutput()
    let captureQueue = DispatchQueue(label: "captureQueue",
                                     qos: .userInitiated,
                                     attributes: [],
                                     autoreleaseFrequency: .workItem)
    let sessionQueue = DispatchQueue(label: "sessionQueue",
                                     attributes: [],
                                     autoreleaseFrequency: .workItem)
    
    let forwardDCT = vDSP.DCT(count: sampleCount,
                              transformType: .II)!
    
    /// The window sequence for reducing spectral leakage.
    let hanningWindow = vDSP.window(ofType: Float.self,
                                    usingSequence: .hanningDenormalized,
                                    count: sampleCount,
                                    isHalfWindow: false)
    
    let dispatchSemaphore = DispatchSemaphore(value: 1)
     
    /// The highest frequency that the app can represent.
    ///
    /// The first call of `captureOutput(_:didOutput:from:)` calculates
    /// this value.
    var nyquistFrequency: Float?
    
    /// A buffer that contains the raw audio data from AVFoundation.
    var rawAudioData = [Int16]()

    /// A reusable array that contains the current frame of time-domain audio data as single-precision
    /// values.
    var timeDomainBuffer = [Float](repeating: 0,
                                   count: sampleCount)
    
    /// A resuable array that contains the frequency-domain representation of the current frame of
    /// audio data.
    var frequencyDomainBuffer = [Float](repeating: 0,
                                        count: sampleCount)
    
    func processData(values: [Int16]) {
        vDSP.convertElements(of: values,
                             to: &timeDomainBuffer)
        
        vDSP.multiply(timeDomainBuffer,
                      hanningWindow,
                      result: &timeDomainBuffer)
        
        forwardDCT.transform(timeDomainBuffer,
                             result: &frequencyDomainBuffer)
        
        vDSP.absolute(frequencyDomainBuffer,
                      result: &frequencyDomainBuffer)
        
        
        vDSP.convert(amplitude: frequencyDomainBuffer,
                     toDecibels: &frequencyDomainBuffer,
                     zeroReference: Float(zeroReference))
        
        let maxFreq = vDSP.indexOfMaximum(frequencyDomainBuffer)
        self.volumeThreshold = Float(UserDefaults.standard.integer(forKey: "inputVolumeThreshold"))
        if maxFreq.1 >= self.volumeThreshold {
            loudestFrequency = Float(maxFreq.0) / Float(MicrophoneInput.sampleCount) * (nyquistFrequency ?? 0)
        } else {
            loudestFrequency = 0
        }
    }
}
