//
//  Constant.swift
//  WWDualCamera
//
//  Created by William.Weng on 2024/7/23.
//

import Foundation

// MARK: - Constant
final class Constant {}

// MARK: - typealias
extension Constant {
    
    typealias MultiCamSessionCost = (hardware: Float, systemPressure: Float)    // 效能指標 (硬體, 系統壓力)
}

// MARK: - enum
extension Constant {
    
    enum MyError: Error {
        case deviceIsEmpty  // 抓不到該鏡頭
        case addInput       // 無法加入輸入鏡頭
    }
}
