//
//  RouteNode.swift
//  luffyRun
//
//  Created by laihj on 2022/12/29.
//

import Foundation
import CoreLocation

final class RouteNode:NSObject,NSCoding {

    var location: CLLocation
    var date: Date
    
    init(location: CLLocation, date:Date) {
        self.location = location
        self.date = date
    }
    
    required convenience init?(coder: NSCoder) {
        let location = coder.decodeObject(forKey: "location") as! CLLocation
        let date = coder.decodeObject(forKey: "date") as! Date
        self.init(location: location, date: date)
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(location,forKey: "location")
        coder.encode(date,forKey: "date")
    }
}
