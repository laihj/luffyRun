//
//  RunEvent.swift
//  luffyRun
//
//  Created by laihj on 2023/3/15.
//

import Foundation
import HealthKit

final class RunEvent: NSObject,NSSecureCoding {
    static var supportsSecureCoding = true
    
    var startDate: Date
    var endDate: Date
    var type: HKWorkoutEventType
    var metadata: [String : Any]?
    
    init(startDate:Date,endDate:Date,type: HKWorkoutEventType, metadata: [String : Any]?) {
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.metadata = metadata
    }
    
    convenience init(event:HKWorkoutEvent) {
        self.init(startDate:event.dateInterval.start,endDate: event.dateInterval.end,type: event.type, metadata: event.metadata)
    }

    
    
    required convenience init?(coder: NSCoder) {
        let startDate = coder.decodeObject(forKey: "startDate") as! Date
        let endDate = coder.decodeObject(forKey: "endDate") as! Date
        let type = coder.decodeInteger(forKey: "type")
        let metadata = coder.decodeObject(forKey: "metadata") as? [String : Any]

        self.init(startDate:startDate,endDate:endDate, type: HKWorkoutEventType(rawValue:type)!, metadata: metadata)
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(startDate,forKey: "startDate")
        coder.encode(endDate,forKey: "endDate")
        coder.encode(type.rawValue,forKey: "type")
        coder.encode(metadata,forKey: "metadata")
    }
}
