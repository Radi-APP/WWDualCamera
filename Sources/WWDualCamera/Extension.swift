//
//  Extension.swift
//  WWDualCamera
//
//  Created by William.Weng on 2024/7/23.
//

import AVFoundation

// MARK: - AVCaptureSession (function)
extension AVCaptureSession {
    
    /// 加入手機設備 (相機、麥克風…)
    /// - Parameters:
    ///   - device: AVCaptureDevice
    ///   - isConnections: Bool
    /// - Returns: Result<Bool, Error>
    func _canAddDevice(_ device: AVCaptureDevice, isConnections: Bool) -> Result<Bool, Error> {
        
        switch device._captureInput() {
        case .failure(let error): return .failure(error)
        case .success(let input): return .success(_canAddInput(input, isConnections: isConnections))
        }
    }
    
    /// 設定硬體
    /// - Parameter action: () -> Void
    /// - Returns: T
    func _configuration<T>(action: () -> T) -> T {
        
        beginConfiguration()
        defer { commitConfiguration() }
        
        return action()
    }
}

// MARK: - AVCaptureMultiCamSession (static function)
extension AVCaptureMultiCamSession {
    
    /// [是否支援多鏡頭同時動作](https://applealmond.com/posts/58750)
    /// - Returns: [Bool](https://developer.apple.com/documentation/avfoundation/avcapturemulticamsession/3183002-multicamsupported)
    static func _isSupported() -> Bool {
        return AVCaptureMultiCamSession.isMultiCamSupported
    }
    
    /// 當前設備支持的最大同時使用鏡頭數 (真的加上Session就知道了)
    /// - Parameter deviceTypes: 要支援的類型
    /// - Returns: Int
    static func _supportCount(deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera]) -> Int {
        
        guard _isSupported() else { return 1 }
        
        let session = AVCaptureMultiCamSession()
        let devices = AVCaptureDevice._discovery(deviceTypes: deviceTypes, mediaType: .video, position: .unspecified)
        
        let count = devices.compactMap { device -> Bool? in
            switch session._canAddDevice(device, isConnections: false) {
            case .failure(_): return nil
            case .success(let isSuccess): return (!isSuccess) ? nil : true
            }
        }.count
        
        return count
    }
}

// MARK: - AVCaptureMultiCamSession
extension AVCaptureMultiCamSession {
    
    /// [硬體 / 系統的用量指標](https://xiaodongxie1024.github.io/2019/04/15/20190413_iOS_VideoCaptureExplain/)
    /// - Returns: SessionCost
    func _cost() -> Constant.MultiCamSessionCost {
        return (hardware: hardwareCost, systemPressure: systemPressureCost)
    }
    
    /// 安全的移除連接
    /// - Parameter connection: AVCaptureConnection?
    /// - Returns: Bool
    func _canRemoveConnection(_ connection: AVCaptureConnection?) -> Bool {
        
        return _configuration {
            
            guard let connection = connection,
                  connections.contains(connection)
            else {
                return false
            }
            
            removeConnection(connection)
            return true
        }
    }
}

// MARK: - AVCaptureDevice (static function)
extension AVCaptureDevice {
    
    /// [取得該選項的影音裝置](https://www.wwdcnotes.com/notes/wwdc19/249/)
    /// - Parameters:
    ///   - deviceType: [AVCaptureDevice.DeviceType](https://blog.csdn.net/u011686167/article/details/130795604)
    ///   - mediaType: AVMediaType?
    ///   - position: AVCaptureDevice.Position
    /// - Returns: AVCaptureDevice?
    static func _default(_ deviceType: AVCaptureDevice.DeviceType, for mediaType: AVMediaType?, position: AVCaptureDevice.Position) -> AVCaptureDevice? { return AVCaptureDevice.default(deviceType, for: mediaType, position: position) }
    
    /// 搜尋影音裝置
    /// - Parameters:
    ///   - deviceTypes: [AVCaptureDevice.DeviceType]
    ///   - mediaType: AVMediaType?
    ///   - position: AVCaptureDevice.Position
    /// - Returns: [AVCaptureDevice]
    static func _discovery(deviceTypes: [AVCaptureDevice.DeviceType], mediaType: AVMediaType?, position: AVCaptureDevice.Position) -> [AVCaptureDevice] {
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: mediaType, position: position).devices
        return devices
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

// MARK: - AVCaptureDeviceInput (function)
extension AVCaptureDeviceInput {
    
    /// 取得該媒體類型的Port
    /// - Parameter mediaType: AVMediaType
    /// - Returns: AVCaptureInput.Port?
    func _port(forType mediaType: AVMediaType) -> AVCaptureInput.Port? {
        return ports.first(where: { $0.mediaType == mediaType })
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
    
    /// 加入新的連接
    /// - Parameter connection: AVCaptureConnection?
    /// - Returns: Bool
    func _canAddConnection(_ connection: AVCaptureConnection?) -> Bool {
        
        return _configuration {
            
            guard let connection = connection,
                  canAddConnection(connection)
            else {
                return false
            }
            
            addConnection(connection)
            return true
        }
    }
    
    /// [產生、設定AVCaptureVideoPreviewLayer](https://www.jianshu.com/p/95f2cd87ad83)
    /// - Parameters:
    ///   - frame: [CGRect](https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer/1387426-init)
    ///   - videoGravity: [AVLayerVideoGravity => .resizeAspectFill](https://xiaodongxie1024.github.io/2019/04/15/20190413_iOS_VideoCaptureExplain/)
    ///   - isConnections: [Bool](https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer/1387426-init)
    /// - Returns: AVCaptureVideoPreviewLayer
    func _previewLayer(with frame: CGRect, videoGravity: AVLayerVideoGravity, isConnections: Bool) -> AVCaptureVideoPreviewLayer {
        
        let previewLayer = isConnections ? AVCaptureVideoPreviewLayer(session: self) : AVCaptureVideoPreviewLayer(sessionWithNoConnection: self)
        
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
