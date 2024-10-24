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
    
    enum MyError: Error, CustomDebugStringConvertible {
        
        var debugDescription: String { message() }
        
        case deviceIsEmpty
        case notAddInput
        case notAddOutput
        case notSupport
        case notAddConnection
        case isNotExist
        
        /// 訊息說明
        /// - Returns: String
        func message() -> String {
            
            switch self {
            case .deviceIsEmpty: return "抓不到該鏡頭"
            case .notAddInput: return "無法加入輸入裝置"
            case .notAddOutput: return "無法加入資料輸出"
            case .notSupport: return "不支援該功能"
            case .notAddConnection: return "無法加入連接"
            case .isNotExist: return "該屬性不存在"
            }
        }
    }
}
