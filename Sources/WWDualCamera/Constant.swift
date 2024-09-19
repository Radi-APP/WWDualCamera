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
        case notAddInput    // 無法加入輸入裝置
        case notAddOutput   // 無法加入資料輸出
        case notSupport     // 不支援該功能
    }
}
