//
//  RecordHeartRate.swift
//  luffyRun
//
//  Created by laihj on 2022/12/27.
//

import Foundation
import CoreData

final class RecordHeartRate:NSManagedObject {
    @NSManaged var heart: Int16
    @NSManaged var date: Date
    
    static func insert(into context:NSManagedObjectContext) -> RecordHeartRate {
        let heart:RecordHeartRate = context.insertObject()
        return heart
    }
}

extension RecordHeartRate: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
}
