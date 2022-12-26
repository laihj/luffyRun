//
//  PaceZone.swift
//  luffyRun
//
//  Created by laihj on 2022/12/26.
//

import Foundation
import CoreData

final class PaceZone:NSManagedObject {
    @NSManaged var zone1: Int16
    @NSManaged var zone2: Int16
    @NSManaged var zone3: Int16
    @NSManaged var zone4: Int16
    @NSManaged var zone5: Int16
    @NSManaged var zone6: Int16
    @NSManaged fileprivate(set) var update: Date
    
    static func insert(into context:NSManagedObjectContext) -> PaceZone {
        let paceZone:PaceZone = context.insertObject()
        paceZone.update = Date()
        return paceZone
    }
    
    static func lastedPaceZone(in context:NSManagedObjectContext) -> PaceZone? {
        guard let paceZone = fetch(in: context) else {
            let paceZone = PaceZone.insert(into: context)
            paceZone.zone1 = 127
            paceZone.zone2 = 148
            paceZone.zone3 = 162
            paceZone.zone4 = 167
            paceZone.zone5 = 177
            paceZone.zone6 = 255
            try! context.save()
            return paceZone
        }
        return paceZone
    }
    
    static func fetch(in context:NSManagedObjectContext) -> PaceZone? {
        let request = PaceZone.sortedFetchRequest
        request.fetchBatchSize = 1
        request.returnsObjectsAsFaults = false
        return try! context.fetch(request).first
    }
}

extension PaceZone: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(update), ascending: false)]
    }
    
}
