//
//  Record.swift
//  luffyRun
//
//  Created by laihj on 2022/12/14.
//

import Foundation
import CoreData

final class Record:NSManagedObject {
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date
    @NSManaged var heartRate:HeartRate
    @NSManaged var paceZone:PaceZone
    @NSManaged var heartbeat:[HeartBeat]?
    @NSManaged var routes:[RouteNode]?
    @NSManaged var source: String
    @NSManaged var distance:NSNumber?
    @NSManaged var step:NSNumber?
    @NSManaged var kCal:NSNumber?
    @NSManaged var averageSLength:NSNumber?
    @NSManaged var avaragePace:NSNumber?
    @NSManaged var avarageHeart:NSNumber?
    @NSManaged var avarageWatt:NSNumber?
    
    static func insert(into context:NSManagedObjectContext) -> Record {
        let record:Record = context.insertObject()
        record.startDate = Date()
        record.heartRate = HeartRate.lastedHeadRate(in: context)!
        record.paceZone = PaceZone.lastedPaceZone(in: context)!
        return record
    }
}

extension Record: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(startDate), ascending: false)]
    }
    
}
