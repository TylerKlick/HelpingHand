////
////  DataFrame+Helper.swift
////  Helping Hand
////
////  Created by Tyler Klick on 7/24/25.
////
//
//import Foundation
//import CoreData
//
//extension DataFrame {
//    
//    var sEMGData: Data {
//        get { sEMGData_ ?? Data() }
//        set { sEMGData_ = newValue }
//    }
//    
//    var imuData: Data {
//        get { imuData_ ?? Data() }
//        set { imuData_ = newValue }
//    }
//    
//    var timeStamp: Date {
//        get { timeStamp_ ?? Date() }
//        set { timeStamp_ = newValue }
//    }
//    
//    var label: String {
//        get { label_ ?? "" }
//        set { label_ = newValue }
//    }
//    
//    var frameID: UUID {
//        get { frameID_ ?? UUID() }
//        set { frameID_ = newValue }
//    }
//    
//    convenience init(sEMGData: Data, imuData: Data, timeStamp: Date, label: String, frameID: UUID) {
//        
//    }
//}
