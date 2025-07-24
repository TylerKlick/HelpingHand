////
////  SessionSettings+Helper.swift
////  Helping Hand
////
////  Created by Tyler Klick on 7/24/25.
////
//
//import Foundation
//import CoreData
//
//extension SessionSettings {
//    
//    var channelMap: NSObject {
//        get { channelMap_ ?? NSNull() }
//        set { channelMap_ = newValue }
//    }
//    
//    var sEMGSampleRate: Double {
//        get { sEMGSampleRate_ }
//        set { sEMGSampleRate_ = newValue }
//    }
//    
//    var imuSampleRate: Double {
//        get { imuSampleRate_ }
//        set { imuSampleRate_ = newValue }
//    }
//    
//    var overlapRatio: Float {
//        get { overlapRatio_ }
//        set { overlapRatio_ = newValue }
//    }
//    
//    var windowSize: Int32 {
//        get { windowSize_ }
//        set { windowSize_ = newValue }
//    }
//    
//    var windowType: String {
//        get { windowType_ ?? "hamming" }
////        set { windowType_ = newValue }
//    }
//}
