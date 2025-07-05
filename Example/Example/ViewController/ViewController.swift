//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/1/1.
//

import UIKit
import AVFoundation
import WWDualCamera

// MARK: - ViewController
final class ViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var subView: UIView!
    
    private var cameraOutputs: [AVCaptureVideoDataOutput] = []
    private var cameraPreviewLayers: [AVCaptureVideoPreviewLayer] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initSetting()
        _ = WWDualCamera.shared.start()
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 初始化設定
    func initSetting() {
        
        // 获取屏幕尺寸
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        
        // 计算上下各占一半的frame
        let topHalfFrame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight / 2)
        let bottomHalfFrame = CGRect(x: 0, y: screenHeight / 2, width: screenWidth, height: screenHeight / 2)
        
        let inputs: [WWDualCamera.CameraSessionInput] = [
            (frame: topHalfFrame, deviceType: .builtInWideAngleCamera, position: .front),      // 前置摄像头在上半部分
            (frame: bottomHalfFrame, deviceType: .builtInWideAngleCamera, position: .back),    // 后置摄像头在下半部分
        ]
        
        let outputs = WWDualCamera.shared.sessionOutputs(inputs: inputs)
        
        for (index, info) in outputs.enumerated() {
            
            guard let output = info.output,
                  let previewLayer = info.previewLayer
            else {
                return
            }
            
            // 移除圆角效果，让两个摄像头显示区域一样大
            // if (index == 1) { previewLayer.cornerRadius = subView.frame.width * 0.5 }
            
            cameraOutputs.append(output)
            cameraPreviewLayers.append(previewLayer)
            view.layer.addSublayer(previewLayer)
        }
    }
}
