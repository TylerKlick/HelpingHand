//
//  SessionSettings+CoreDataProperties.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/23/25.
//
//

import Foundation
import CoreData


extension SessionSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionSettings> {
        return NSFetchRequest<SessionSettings>(entityName: "SessionSettings")
    }

    @NSManaged public var channelMap: NSObject?
    @NSManaged public var eSMGSampleRate: Double
    @NSManaged public var imuSampleRate: Double
    @NSManaged public var overlapRatio: Float
    @NSManaged public var windowSize: Int32
    @NSManaged public var windowType: String?

}

extension SessionSettings : Identifiable {

}
