//
//  ZonePace.swift
//  luffyRun
//
//  Created by laihj on 2023/2/8.
//

import Foundation


final class ZonePace:NSObject,NSCoding {
    var id:UUID
    var second:Double
    var distance:Double
    
    init(id:UUID, second: Double, distance: Double) {
        self.id = id
        self.second = second
        self.distance = distance
    }

    func paceMinite()-> Double {
        return pace(second: second, distance: distance)
    }
    
    convenience init(second: Double, distance: Double) {
        self.init(id: UUID(), second: second, distance: distance)
    }
    
    
    required convenience init?(coder: NSCoder) {
        let id = coder.decodeObject (forKey: "id") as! UUID
        let second = coder.decodeDouble(forKey: "second")
        let distance = coder.decodeDouble(forKey: "distance") 
        self.init(id:id, second: second, distance: distance)
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(id,forKey: "id")
        coder.encode(second,forKey: "second")
        coder.encode(distance,forKey: "distance")
    }
}
