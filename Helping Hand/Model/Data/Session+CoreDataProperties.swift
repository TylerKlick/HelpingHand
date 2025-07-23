//
//  Session+CoreDataProperties.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/23/25.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var sessionID: UUID?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var mode: String?
    @NSManaged public var label: String?
    @NSManaged public var sessionSettings: SessionSettings?
    @NSManaged public var frames: NSSet?

}

// MARK: Generated accessors for frames
extension Session {

    @objc(addFramesObject:)
    @NSManaged public func addToFrames(_ value: DataFrame)

    @objc(removeFramesObject:)
    @NSManaged public func removeFromFrames(_ value: DataFrame)

    @objc(addFrames:)
    @NSManaged public func addToFrames(_ values: NSSet)

    @objc(removeFrames:)
    @NSManaged public func removeFromFrames(_ values: NSSet)

}

extension Session : Identifiable {

}
