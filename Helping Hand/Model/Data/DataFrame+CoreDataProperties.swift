//
//  DataFrame+CoreDataProperties.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/23/25.
//
//

import Foundation
import CoreData


extension DataFrame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataFrame> {
        return NSFetchRequest<DataFrame>(entityName: "DataFrame")
    }

    @NSManaged public var frameIndex: Int64
    @NSManaged public var timeStamp: Date?
    @NSManaged public var eSMGData: Data?
    @NSManaged public var imuData: Data?
    @NSManaged public var session: Session?

}

extension DataFrame : Identifiable {

}
