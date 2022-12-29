//
//  Location.swift
//  luffyRun
//
//  Created by laihj on 2022/12/27.
//

import Foundation
import CoreData
import CoreLocation

final class Location:NSManagedObject {
    @NSManaged var location: CLLocation
    @NSManaged var date: Date
    
    static func insert(into context:NSManagedObjectContext) -> Location {
        let location:Location = context.insertObject()
        return location
    }
}

extension Location: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
}
