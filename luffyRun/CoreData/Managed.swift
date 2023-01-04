//
//  Managed.swift
//  luffyRun
//
//  Created by laihj on 2022/12/15.
//

import CoreData


protocol Managed: AnyObject, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}


extension Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }

    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}


extension Managed where Self: NSManagedObject {
    static var entityName: String { return entity().name!  }
}
