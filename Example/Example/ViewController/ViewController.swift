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
        
        let inputs: [WWDualCamera.CameraSessionInput] = [
            (frame: mainView.frame, deviceType: .builtInWideAngleCamera, position: .back),
            (frame: subView.frame, deviceType: .builtInWideAngleCamera, position: .front),
        ]
        
        let outputs = WWDualCamera.shared.sessionOutputs(inputs: inputs)
        
        for (index, info) in outputs.enumerated() {
            
            guard let output = info.output,
                  let previewLayer = info.previewLayer
            else {
                return
            }
            
            if (index == 1) { previewLayer.cornerRadius = subView.frame.width * 0.5 }
            
            cameraOutputs.append(output)
            cameraPreviewLayers.append(previewLayer)
            view.layer.addSublayer(previewLayer)
        }
    }
}
