//
//  Extension.swift
//  WWDualCamera
//
//  Created by William.Weng on 2024/7/23.
//

import AVFoundation

// MARK: - AVCaptureMultiCamSession
extension AVCaptureMultiCamSession {
    
    /// [硬體 / 系統的用量指標](https://xiaodongxie1024.github.io/2019/04/15/20190413_iOS_VideoCaptureExplain/)
    /// - Returns: SessionCost
    func _cost() -> Constant.MultiCamSessionCost {
        return (hardware: hardwareCost, systemPressure: systemPressureCost)
    }
}

// MARK: - AVCaptureDevice (function)
extension AVCaptureDevice {
    
    /// 取得該裝置的Input => NSCameraUsageDescription / NSMicrophoneUsageDescription
    func _captureInput() -> Result<AVCaptureDeviceInput, Error> {
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: self)
            return .success(deviceInput)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - AVCaptureSession (function)
extension AVCaptureSession {
        
    /// 將影音的Input加入Session (可以不連接)
    /// - Parameters:
    ///   - input: AVCaptureInput?
    ///   - isConnections: [Bool](https://www.cnblogs.com/zouchenxi/p/14900858.html)
    /// - Returns: Bool
    func _canAddInput(_ input: AVCaptureInput?, isConnections: Bool) -> Bool {
        
        guard let input = input,
              canAddInput(input)
        else {
            return false
        }
        
        (isConnections) ? addInput(input) : addInputWithNoConnections(input)
        return true
    }
    
    /// 將影音的Output加入Session (可以不連接)
    /// - Parameters:
    ///   - output: AVCaptureOutput?
    ///   - isConnections: Bool
    /// - Returns: Bool
    func _canAddOutput(_ output: AVCaptureOutput?, isConnections: Bool) -> Bool {
        
        guard let output = output,
              canAddOutput(output)
        else {
            return false
        }
        
        (isConnections) ? addOutput(output) : addOutputWithNoConnections(output)
        return true
    }
    
    /// [產生、設定AVCaptureVideoPreviewLayer](https://www.jianshu.com/p/95f2cd87ad83)
    /// - Parameters:
    ///   - frame: [CGRect](https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer/1387426-init)
    ///   - videoGravity: [AVLayerVideoGravity => .resizeAspectFill](https://xiaodongxie1024.github.io/2019/04/15/20190413_iOS_VideoCaptureExplain/)
    /// - Returns: AVCaptureVideoPreviewLayer
    func _previewLayer(with frame: CGRect, videoGravity: AVLayerVideoGravity) -> AVCaptureVideoPreviewLayer {
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self)
        
        previewLayer.frame = frame
        previewLayer.videoGravity = videoGravity
        
        return previewLayer
    }
}

// MARK: - AVCaptureVideoDataOutput (static function)
extension AVCaptureVideoDataOutput {
    
    /// 建立AVCaptureVideoDataOutput (影像)
    /// - Parameters:
    ///   - delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    ///   - videoSettings: [String : Any]?
    ///   - queue: DispatchQueue?
    ///   - isAlwaysDiscardsLateVideoFrames: [Bool](https://blog.csdn.net/github_36843038/article/details/114550865)
    /// - Returns: AVCaptureVideoDataOutput
    static func _build(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?, isAlwaysDiscardsLateVideoFrames: Bool, videoSettings: [String : Any], queue: DispatchQueue?) -> AVCaptureVideoDataOutput {
        
        let output = AVCaptureVideoDataOutput()
        
        output.videoSettings = videoSettings
        output.setSampleBufferDelegate(delegate, queue: queue)
        output.alwaysDiscardsLateVideoFrames = isAlwaysDiscardsLateVideoFrames
        
        return output
    }
}

// MARK: - AVCaptureVideoPreviewLayer (function)
extension AVCaptureVideoPreviewLayer {
    
    /// 設定防手震模式
    /// - Parameters:
    ///   - mode: AVCaptureVideoStabilizationMode
    ///   - device: AVCaptureDevice
    /// - Returns: Bool
    func _stabilizationMode(_ mode: AVCaptureVideoStabilizationMode, device: AVCaptureDevice) -> Bool {
        return connection?._stabilizationMode(mode, device: device) ?? false
    }
}

// MARK: - AVCaptureConnection (function)
extension AVCaptureConnection {
    
    /// [設定防手震模式](https://stackoverflow.com/questions/77030040/how-to-activate-preferredvideostabilizationmode-for-avcapturesessionpresetphoto)
    /// - Parameters:
    ///   - mode: AVCaptureVideoStabilizationMode
    ///   - device: AVCaptureDevice
    /// - Returns: Bool
    func _stabilizationMode(_ mode: AVCaptureVideoStabilizationMode, device: AVCaptureDevice) -> Bool {
        
        guard device.activeFormat.isVideoStabilizationModeSupported(mode) else { return false }
        
        preferredVideoStabilizationMode = mode
        return true
    }
}
