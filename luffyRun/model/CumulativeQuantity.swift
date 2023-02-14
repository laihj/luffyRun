//
//  CumulativeQuantity.swift
//  luffyRun
//
//  Created by laihj on 2023/1/6.
//

import Foundation
import HealthKit

final class CumulativeQuantity:NSObject,NSSecureCoding {
    static var supportsSecureCoding = true

    var value: Double
    var startDate: Date
    var endDate: Date
    
    init(value:Double, startDate:Date, endDate:Date) {
        self.value = value
        self.startDate = startDate
        self.endDate = endDate
    }
    
    convenience init(sample:HKCumulativeQuantitySample, unit:HKUnit) {
        let value = sample.quantity.doubleValue(for: unit)
        let startDate = sample.startDate
        let endDate = sample.endDate
        self.init(value: value, startDate: startDate, endDate: endDate)
    }
    
    required convenience init?(coder: NSCoder) {
        let value = coder.decodeDouble(forKey: "value")
        let startDate = coder.decodeObject(forKey: "startDate") as! Date
        let endDate = coder.decodeObject(forKey: "endDate") as! Date
        self.init(value: value, startDate: startDate, endDate: endDate)
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(value,forKey: "value")
        coder.encode(startDate,forKey: "startDate")
        coder.encode(endDate,forKey: "endDate")
    }
}
