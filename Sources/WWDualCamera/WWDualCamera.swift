//
//  WWDualCamera.swift
//  WWDualCamera
//
//  Created by William.Weng on 2024/7/23.
//

import UIKit
import AVFoundation

/// MARK: - 產生雙鏡頭輸出
open class WWDualCamera: NSObject {
    
    public typealias CameraSessionInput = (
        frame: CGRect,                              // 放在哪個位置上面
        deviceType: AVCaptureDevice.DeviceType,     // 鏡頭裝置類型
        position: AVCaptureDevice.Position          // 鏡頭前後位置
    )
    
    public typealias CameraSessionOutput = (
        device: AVCaptureDevice?,                   // 鏡頭裝置
        output: AVCaptureVideoDataOutput?,          // 影像輸出
        previewLayer: AVCaptureVideoPreviewLayer?,  // 預覽畫面
        error: Error?                               // 錯誤
    )
    
    public typealias MultiCamSessionCost = (
        hardware: Float,                            // 硬體壓力 (0.0 ~ 1.0)
        systemPressure: Float                       // 系統壓力 (0.0 ~ 1.0)
    )
    
    public let multiSession = AVCaptureMultiCamSession()
    
    /// [是否支援多鏡頭同時動作](https://developer.apple.com/documentation/avfoundation/avcapturemulticamsession/3183002-multicamsupported)
    public var isMultiCamSupported: Bool { AVCaptureMultiCamSession.isMultiCamSupported }
    
    /// 是否正在預覽畫面
    public var isRunning: Bool { multiSession.isRunning }
    
    /// 當前設備支持的最大同時使用鏡頭數
    public var supportCount: Int { AVCaptureMultiCamSession._supportCount() }
        
    private override init() {}
    
    public static let shared = WWDualCamera()
}

/// MARK: - 公開工具
public extension WWDualCamera {
    
    /// 開始執行
    /// - Returns: Result<[AVCaptureConnection], Error>
    func start() -> [AVCaptureConnection] {
        
        multiSession.startRunning()
        return multiSession.connections
    }
    
    /// 關閉執行
    /// - Returns: 有連上Session的Connection
    func stop() -> [AVCaptureConnection] {
        
        multiSession.stopRunning()
        return multiSession.connections
    }
    
    /// 加入額外裝置輸入 (可以不連接)
    /// - Returns: Bool
    /// - Parameters:
    ///   - inputs: [AVCaptureInput]
    ///   - isConnections: Bool
    func addInputs<T: AVCaptureInput>(_ inputs: [T], isConnections: Bool = true) -> Bool {
        
        var isSuccess = true
        inputs.forEach { isSuccess = isSuccess && multiSession._canAddInput($0, isConnections: isConnections)}
        
        return isSuccess
    }
    
    /// 加入額外資源輸出 (可以不連接)
    /// - Parameters:
    ///   - outputs: [AVCaptureOutput]
    ///   - isConnections: Bool
    /// - Returns: Bool
    func addOutputs<T: AVCaptureOutput>(_ outputs: [T], isConnections: Bool = true) -> Bool {
        
        var isSuccess = true
        outputs.forEach { isSuccess = isSuccess && multiSession._canAddOutput($0, isConnections: isConnections) }
        
        return isSuccess
    }
    
    /// 相關的設定 (切換硬體)
    /// - Parameter action: AVCaptureMultiCamSession
    func configuration(action: (AVCaptureMultiCamSession) -> Void) {
        
        multiSession.beginConfiguration()
        defer { multiSession.commitConfiguration() }
        
        action(multiSession)
    }
    
    /// 移除輸入裝置
    /// - Parameter inputs: [AVCaptureInput]
    /// - Returns: AVCaptureMultiCamSession所剩下的inputs
    func removeInputs(_ inputs: [AVCaptureInput]) -> [AVCaptureInput] {
        inputs.forEach { multiSession.removeInput($0) }
        return multiSession.inputs
    }
    
    /// 移除所有輸入裝置
    /// - Returns: AVCaptureMultiCamSession所剩下的inputs
    func removeAllInputs() -> [AVCaptureInput] {
        removeInputs(multiSession.inputs)
    }
    
    /// 移除輸出裝置
    /// - Parameter inputs: [AVCaptureInput]
    /// - Returns: AVCaptureMultiCamSession所剩下的outputs
    func removeOutputs(_ outputs: [AVCaptureOutput]) -> [AVCaptureOutput] {
        outputs.forEach { multiSession.removeOutput($0) }
        return multiSession.outputs
    }
    
    /// 移除所有輸出裝置
    /// - Returns: AVCaptureMultiCamSession所剩下的outputs
    func removeAllOutputs() -> [AVCaptureOutput] {
        removeOutputs(multiSession.outputs)
    }
    
    /// 產生輸出資訊
    /// - Parameters:
    ///   - delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    ///   - inputs: [CameraSessionInput]
    ///   - videoGravity: AVLayerVideoGravity
    ///   - stabilizationMode: AVCaptureVideoStabilizationMode
    /// - Returns: [CameraSessionOutput]
    func sessionOutputs(delegate: AVCaptureVideoDataOutputSampleBufferDelegate? = nil, inputs: [CameraSessionInput], videoGravity: AVLayerVideoGravity = .resizeAspectFill, stabilizationMode: AVCaptureVideoStabilizationMode = .auto) -> [CameraSessionOutput] {
        
        let outputs = outputSetting(delegate: delegate, inputs: inputs, videoGravity: videoGravity, isAlwaysDiscardsLateVideoFrames: true, stabilizationMode: stabilizationMode)
        return outputs
    }
    
    /// [硬體 / 系統的用量指標](https://xiaodongxie1024.github.io/2019/04/15/20190413_iOS_VideoCaptureExplain/)
    /// - Returns: SessionCost
    func cost() -> MultiCamSessionCost {
        return multiSession._cost()
    }
}

/// MARK: - 小工具
private extension WWDualCamera {
    
    /// 影像輸出設定
    /// - Parameters:
    ///   - delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    ///   - inputs: [CameraSessionInput]
    ///   - outputs: [CameraSessionOutput]
    ///   - videoGravity: AVLayerVideoGravity
    ///   - isAlwaysDiscardsLateVideoFrames: [Bool](https://blog.csdn.net/github_36843038/article/details/114550865)
    /// - Returns: [CameraSessionOutput]
    func outputSetting(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?, inputs: [CameraSessionInput], videoGravity: AVLayerVideoGravity, isAlwaysDiscardsLateVideoFrames: Bool, stabilizationMode: AVCaptureVideoStabilizationMode) -> [CameraSessionOutput] {
        
        var outputs: [CameraSessionOutput] = []
        
        inputs.forEach { input in
            
            let _device = AVCaptureDevice.DiscoverySession(deviceTypes: [input.deviceType], mediaType: .video, position: input.position).devices.first
            var _output: CameraSessionOutput = (device: _device, output: nil, previewLayer: nil, error: nil)
            
            defer { outputs.append(_output) }
            
            guard let _device = _device else { _output.error = Constant.MyError.deviceIsEmpty; return }
            
            switch _device._captureInput() {
            
            case .failure(let error): _output.error = error
            case .success(let _input):
                
                guard multiSession._canAddInput(_input, isConnections: true) else { _output.error = Constant.MyError.notAddInput; return }
                
                let queue = DispatchQueue(label: "\(Date().timeIntervalSince1970)")
                let output = AVCaptureVideoDataOutput._build(delegate: delegate, isAlwaysDiscardsLateVideoFrames: isAlwaysDiscardsLateVideoFrames, videoSettings: [:], queue: queue)
                
                guard multiSession._canAddOutput(output, isConnections: true) else { _output.error = Constant.MyError.notAddOutput; return }
                
                let previewLayer = multiSession._previewLayer(with: input.frame, videoGravity: videoGravity)
                previewLayer._stabilizationMode(stabilizationMode, device: _device)
                
                _output.output = output
                _output.previewLayer = previewLayer
            }
        }
        
        return outputs
    }
}
