import Foundation
import AVFoundation
import SwiftUI
import Combine
import CoreImage

class HeartRateManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var isFingerDetected: Bool = false
    @Published var bpm: Int = 0
    
    private var captureSession: AVCaptureSession?
    private let context = CIContext()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    private var detectionConfidence = 0
    private var removalConfidence = 0
    private let confidenceThreshold = 4
    
    // Анализ сигнала
    private var redValues: [Double] = []
    private var timestamps: [TimeInterval] = []
    
    private let maxSamples = 240          // ~8 секунд при 30FPS
    private let minSamples = 60           // минимум ~2 секунд данных
    private var lastBPMUpdate = Date.distantPast
    
    // MARK: - START CAMERA
    func start() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            print("Camera not authorized")
            return
        }
        
        sessionQueue.async {
            
            if self.captureSession != nil { return }
            
            let session = AVCaptureSession()
            session.sessionPreset = .low
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                print("Camera unavailable")
                return
            }
            session.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            
            self.captureSession = session
            session.startRunning()
            
            // Torch ON
            if device.hasTorch {
                try? device.lockForConfiguration()
                try? device.setTorchModeOn(level: 1.0)   // MAX BRIGHTNESS
                device.unlockForConfiguration()
            }
        }
    }
    
    // MARK: - STOP CAMERA
    func stop() {
        sessionQueue.async {
            guard let session = self.captureSession else { return }
            
            self.captureSession = nil
            
            if let deviceInput = session.inputs.first as? AVCaptureDeviceInput {
                if deviceInput.device.hasTorch {
                    try? deviceInput.device.lockForConfiguration()
                    deviceInput.device.torchMode = .off
                    deviceInput.device.unlockForConfiguration()
                }
            }
            
            session.stopRunning()
            
            DispatchQueue.main.async {
                self.isFingerDetected = false
                self.bpm = 0
            }
            
            self.resetSignal()
        }
    }
    
    // MARK: - FRAME PROCESSING
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        guard let filter = CIFilter(name: "CIAreaAverage") else { return }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: ciImage.extent), forKey: kCIInputExtentKey)
        
        guard let outputImage = filter.outputImage else { return }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        let r = Double(bitmap[0])
        let g = Double(bitmap[1])
        let b = Double(bitmap[2])
        
        // DETECT FINGER
        let fingerIsOn = r > 50 && r > g + 10 && r > b + 10
        
        if fingerIsOn {
            detectionConfidence += 1
            removalConfidence = 0
            
            if detectionConfidence > confidenceThreshold && !isFingerDetected {
                DispatchQueue.main.async {
                    self.isFingerDetected = true
                    self.bpm = 0
                }
                resetSignal()
            }
            
        } else {
            detectionConfidence = 0
            removalConfidence += 1
            
            if removalConfidence > confidenceThreshold && isFingerDetected {
                DispatchQueue.main.async {
                    self.isFingerDetected = false
                    self.bpm = 0
                }
                resetSignal()
            }
        }
        
        // CALCULATE BPM
        if isFingerDetected {
            processSample(r)
        }
    }
    
    // MARK: - PROCESS SAMPLE
    private func processSample(_ red: Double) {
        
        let now = Date().timeIntervalSince1970
        
        // Сглаживаем
        let smoothed = (red + (redValues.last ?? red)) / 2.0
        
        redValues.append(smoothed)
        timestamps.append(now)
        
        if redValues.count > maxSamples {
            redValues.removeFirst()
            timestamps.removeFirst()
        }
        
        guard redValues.count >= minSamples else { return }
        
        // Обновление раз в 1 секунду
        if Date().timeIntervalSince(lastBPMUpdate) < 1.0 { return }
        lastBPMUpdate = Date()
        
        if let bpm = calculateBPM() {
            DispatchQueue.main.async {
                self.bpm = bpm
            }
        }
    }
    
    private func resetSignal() {
        redValues.removeAll()
        timestamps.removeAll()
    }
    
    // MARK: - REAL BPM CALCULATION
    private func calculateBPM() -> Int? {
        
        guard redValues.count == timestamps.count else { return nil }
        
        // Удаляем DC-уровень
        let mean = redValues.reduce(0, +) / Double(redValues.count)
        let centered = redValues.map { $0 - mean }
        
        guard let maxVal = centered.max(), maxVal > 0.1 else { return nil }
        
        let threshold = maxVal * 0.3
        
        var peakTimes: [TimeInterval] = []
        
        for i in 1..<(centered.count - 1) {
            if centered[i] > threshold &&
                centered[i] > centered[i - 1] &&
                centered[i] > centered[i + 1] {
                
                peakTimes.append(timestamps[i])
            }
        }
        
        guard peakTimes.count >= 2 else { return nil }
        
        let duration = peakTimes.last! - peakTimes.first!
        guard duration > 0 else { return nil }
        
        let beats = Double(peakTimes.count - 1)
        let bpm = beats / duration * 60.0
        let val = Int(bpm.rounded())
        
        if val < 40 || val > 180 { return nil }
        
        return val
    }
}
