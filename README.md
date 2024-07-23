# WWDualCamera

[![Swift-5.6](https://img.shields.io/badge/Swift-5.6-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-14.0](https://img.shields.io/badge/iOS-14.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![](https://img.shields.io/github/v/tag/William-Weng/WWDualCamera) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- [Simple generation of dual camera functions.](https://blog.csdn.net/u011686167/article/details/130795604)
- [簡單的產生雙鏡頭功能。](https://www.jianshu.com/p/95f2cd87ad83)

![WWZHConverter](./Example.gif)

## [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWDualCamera.git", .upToNextMajor(from: "1.0.0"))
]
```

## 可用函式
|函式|說明|
|-|-|
|start()|開始執行|
|stop()|關閉執行|
|multiCamSupported()|是否支援多鏡頭同時動作|
|sessionOutputs(delegate:inputs:videoGravity:)|產生輸出資訊|

## Example
```swift
import UIKit
import AVFoundation
import WWDualCamera

final class ViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var subView: UIView!
    
    private var cameraOutputs: [AVCaptureVideoDataOutput] = []
    private var cameraPreviewLayers: [AVCaptureVideoPreviewLayer] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initSetting()
        WWDualCamera.shared.start()
    }
}

private extension ViewController {
    
    func initSetting() {
        
        let inputs: [WWDualCamera.CameraSessionInput] = [
            (view: mainView, deviceType: .builtInWideAngleCamera, position: .back),
            (view: subView, deviceType: .builtInWideAngleCamera, position: .front),
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
            mainView.layer.addSublayer(previewLayer)
        }
    }
}
```


