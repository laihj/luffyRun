//
//  CoreDataStack.swift
//  luffyRun
//
//  Created by laihj on 2022/12/15.
//

import Foundation
import CoreData

func createLuffyContainer(completion:
                                @escaping (NSPersistentContainer) -> ())
{
    let container = NSPersistentContainer(name: "luffyRun")
    container.loadPersistentStores { _, error in
        guard error == nil else { fatalError("Failed to load store: \(error!)")
        }
    DispatchQueue.main.async { completion(container) } }
}
