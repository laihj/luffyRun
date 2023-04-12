//
//  HeartRate.swift
//  luffyRun
//
//  Created by laihj on 2022/12/26.
//

import Foundation
import CoreData

final class HeartRate:NSManagedObject {
    @NSManaged var zone1: Int16
    @NSManaged var zone2: Int16
    @NSManaged var zone3: Int16
    @NSManaged var zone4: Int16
    @NSManaged var zone5: Int16
    @NSManaged var max: Int16
    @NSManaged var rest: Int16
    @NSManaged fileprivate(set) var update: Date
    
    static func insert(into context:NSManagedObjectContext) -> HeartRate {
        let heartRate:HeartRate = context.insertObject()
        heartRate.update = Date()
        return heartRate
    }
    
    static func lastedHeadRate(in context:NSManagedObjectContext) -> HeartRate? {
        guard let heartRate = fetch(in: context) else {
            let heartRate = HeartRate.insert(into: context)
            heartRate.rest = 46
            heartRate.max = 184
            heartRate.zone1 = 127
            heartRate.zone2 = 148
            heartRate.zone3 = 162
            heartRate.zone4 = 167
            heartRate.zone5 = 177
            try! context.save()
            return heartRate
        }
        return heartRate
    }
    
    func formatZone(zone:Int) -> String {
        switch(zone) {
        case 5:
            return "\(zone5)"
        case 4:
            return "\(zone4)"
        case 3:
            return "\(zone3)"
        case 2:
            return "\(zone2)"
        case 1:
            return "\(zone1)"
        default:
            return ""
        }
    }
    
    static func fetch(in context:NSManagedObjectContext) -> HeartRate? {
        let request = HeartRate.sortedFetchRequest
        request.fetchBatchSize = 1
        request.returnsObjectsAsFaults = false
        return try! context.fetch(request).first
    }
}

extension HeartRate: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(update), ascending: false)]
    }
    
}

