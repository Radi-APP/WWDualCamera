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

private extension ViewController {
    
   
    func initSetting() {
        
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
       
        let fullScreenFrame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        let frontWidth = screenWidth * 0.35
        let frontHeight = frontWidth * 1.3
        let frontCameraFrame = CGRect(x: screenWidth - frontWidth - 16, y: screenHeight - frontHeight - 32, width: frontWidth, height: frontHeight)
        
        let inputs: [WWDualCamera.CameraSessionInput] = [
            (frame: fullScreenFrame, deviceType: .builtInWideAngleCamera, position: .back),
            (frame: frontCameraFrame, deviceType: .builtInWideAngleCamera, position: .front),
        ]
        
        let outputs = WWDualCamera.shared.sessionOutputs(inputs: inputs)
        
        for (index, info) in outputs.enumerated() {
            
            guard let output = info.output,
                  let previewLayer = info.previewLayer
            else {
                return
            }
            
            if index == 1 {
                previewLayer.cornerRadius = 12
                previewLayer.masksToBounds = true
            }
            
            cameraOutputs.append(output)
            cameraPreviewLayers.append(previewLayer)
            view.layer.addSublayer(previewLayer)
        }
    }
}
