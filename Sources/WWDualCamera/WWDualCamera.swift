//
//  WWDualCamera.swift
//  WWDualCamera
//
//  Created by William.Weng on 2024/7/23.
//

import UIKit
import AVFoundation

/// MARK: - 產生雙鏡頭輸出
open class WWDualCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public typealias CameraSessionInput = (
        view: UIView,                               // 放在哪個UIView上面
        deviceType: AVCaptureDevice.DeviceType,     // 鏡頭裝置類型
        position: AVCaptureDevice.Position          // 鏡頭前後位置
    )
    
    public typealias CameraSessionOutput = (
        deviceType: AVCaptureDevice.DeviceType,     // 鏡頭裝置類型
        output: AVCaptureVideoDataOutput?,          // 影像輸出
        previewLayer: AVCaptureVideoPreviewLayer?,  // 預覽畫面
        error: Error?                               // 錯誤
    )
    
    private var multiSession = AVCaptureMultiCamSession()
    
    private override init() {}
    
    public static let shared = WWDualCamera()
}

/// MARK: - 公開工具
public extension WWDualCamera {

    /// 開始執行
    func start() {
        multiSession.startRunning()
    }
    
    /// 關閉執行
    func stop() {
        multiSession.stopRunning()
    }
    
    /// [是否支援多鏡頭同時動作](https://developer.apple.com/documentation/avfoundation/avcapturemulticamsession/3183002-multicamsupported)
    /// - Returns: Bool
    func multiCamSupported() -> Bool {
        return AVCaptureMultiCamSession.isMultiCamSupported
    }
    
    /// 產生輸出資訊
    /// - Parameters:
    ///   - delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    ///   - inputs: [CameraSessionInput]
    ///   - videoGravity: AVLayerVideoGravity
    /// - Returns: [CameraSessionOutput]
    func sessionOutputs(delegate: AVCaptureVideoDataOutputSampleBufferDelegate? = nil, inputs: [CameraSessionInput], videoGravity: AVLayerVideoGravity = .resizeAspectFill) -> [CameraSessionOutput] {
        let outputs = outputSetting(delegate: delegate, inputs: inputs, videoGravity: videoGravity)
        return outputs
    }
}

/// MARK: - 小工具
private extension WWDualCamera {
    
    /// 影像輸出設定
    /// - Parameters:
    ///   - delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    ///   - inputs: [CameraSessionInput]
    ///   - outputs: [CameraSessionOutput]
    func outputSetting(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?, inputs: [CameraSessionInput], videoGravity: AVLayerVideoGravity) -> [CameraSessionOutput] {
        
        var outputs: [CameraSessionOutput] = []
        
        inputs.forEach { input in
            
            let _device = AVCaptureDevice.DiscoverySession(deviceTypes: [input.deviceType], mediaType: .video, position: input.position).devices.first
            var _output: CameraSessionOutput = (deviceType: input.deviceType, output: nil, previewLayer: nil, error: nil)
            
            if let _device = _device {
                
                switch _device._captureInput() {
                case .failure(let error): outputs.append((deviceType: input.deviceType, output: nil, previewLayer: nil, error: error))
                case .success(let _input):
                    
                    if (multiSession._canAddInput(_input)) {
                        
                        let output = AVCaptureVideoDataOutput()
                        let previewLayer = multiSession._previewLayer(with: input.view.frame, videoGravity: videoGravity)
                        
                        output.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "\(Date().timeIntervalSince1970)"))
                        _output.output = output
                        _output.previewLayer = previewLayer
                        
                    } else {
                        _output.error = Constant.MyError.addInput
                    }
                }
                
            } else {
                _output.error = Constant.MyError.deviceIsEmpty
            }
            
            outputs.append(_output)
        }
        
        return outputs
    }
}
