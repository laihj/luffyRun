//
//  Record.swift
//  luffyRun
//
//  Created by laihj on 2022/12/14.
//

import Foundation
import CoreData
import SwiftUI

enum Zone:Int {
    case zone1 = 0,
    zone2,
    zone3,
    zone4,
    zone5
}

final class Record:NSManagedObject {
    @NSManaged var udid:UUID
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date?
    @NSManaged var heartRate:HeartRate
    @NSManaged var paceZone:PaceZone
    @NSManaged var heartbeat:[DiscreateHKQuanty]?
    @NSManaged var power:[DiscreateHKQuanty]?
    @NSManaged var steps:[CumulativeQuantity]?
    @NSManaged var routes:[RouteNode]?
    @NSManaged var source: String
    @NSManaged var distance:NSNumber?
    @NSManaged var step:NSNumber?
    @NSManaged var kCal:NSNumber?
    @NSManaged var averageSLength:NSNumber?
    
    @NSManaged var heartPace:[ZonePace]?
    
    @NSManaged var minPace:NSNumber?
    @NSManaged var minHeart:NSNumber?
    @NSManaged var minWatt:NSNumber?
    
    @NSManaged var avaragePace:NSNumber?
    @NSManaged var avarageHeart:NSNumber?
    @NSManaged var avarageWatt:NSNumber?
    
    @NSManaged var maxPace:NSNumber?
    @NSManaged var maxHeart:NSNumber?
    @NSManaged var maxWatt:NSNumber?
    
    //天气相关
    @NSManaged var temperature:NSNumber?
    @NSManaged var humidity:NSNumber?
    
    @NSManaged var mets:NSNumber?
    
    //技术
    @NSManaged var verticalOscillation:NSNumber? //垂直振幅
    @NSManaged var runningGroundContactTime:NSNumber? //触地时间
    @NSManaged var avarageCadence:NSNumber?
    
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

//for chart
extension Record {
    
    func avgCadence() -> Int {
        guard let steps = steps else {return 0}
        
//        let allStep = steps.reduce(0.0) { result, step in
//            print("-----")
//            print(step.startDate)
//            print(step.endDate)
//            return result + step.value
//        }
        let second = endDate!.timeIntervalSince1970 - startDate.timeIntervalSince1970
        let avgCan = Int((step?.doubleValue ?? 0.0) / ((second) / 60.0) )
        return avgCan
        

        
//        let cadence:[Int] = steps.map { step in
//            let second = step.endDate.timeIntervalSince1970 - step.startDate.timeIntervalSince1970
//            let count = Int(step.value / ((second) / 60.0) )
//            return count
//        }
//
//        var sumSteps = [CumulativeQuantity]()
//        for (index,_) in steps.enumerated() {
//            if index % 24 == 0 {
//                let slice = steps[index..<min((index+24),steps.count)]
//                if(slice.count < 10) {
//                    continue
//                }
//                let stepCount = slice.reduce(0.0) { result, step in
//                    return result + step.value
//                }
//
//                let step = CumulativeQuantity(value: stepCount, startDate: slice.first!.startDate, endDate: slice.last!.endDate)
//                sumSteps.append(step)
//            }
//        }
//
//        let cadenceSum:[Int] = sumSteps.map { step in
//            let second = step.endDate.timeIntervalSince1970 - step.startDate.timeIntervalSince1970
//            let count = Int(step.value / ((second) / 60.0) )
//            return count
//        }
//

//        let second = endDate!.timeIntervalSince1970 - startDate.timeIntervalSince1970
//        let avgCan = Int(allStep / ((second) / 60.0) )
//        var highestCan = 50
//        var lowestCan = 500
//        _ = cadence.map { can in
//            highestCan = can > highestCan ? can : highestCan
//            lowestCan = can < lowestCan ? can : lowestCan
//        }
//        return (highestCan,lowestCan,avgCan)
        
    }
    
    func heartZoneSecond(heartBeat:[DiscreateHKQuanty]) -> (Double,Double,Double,Double,Double,Double) {
        var (zone5,zone4,zone3,zone2,zone1,allSecond) = (0.0,0.0,0.0,0.0,0.0,0.0)
        for (current,next) in zip(heartBeat,heartBeat.dropFirst()) {
            let second = next.date.timeIntervalSince1970 -  current.date.timeIntervalSince1970
            let value = Int16(current.value)
            
            if value >= heartRate.zone5 {
                zone5 += second
            } else if value >= heartRate.zone4 {
                zone4 += second
            } else if value >= heartRate.zone3 {
                zone3 += second
            } else if value >= heartRate.zone2 {
                zone2 += second
            } else {
                zone1 += second
            }
            allSecond += second
        }
        return (zone5,zone4,zone3,zone2,zone1,allSecond)
    }
    
    func heartRateChartData() -> [BarData] {
        if let heartBeat = heartbeat {
            let (zone5,zone4,zone3,zone2,zone1,allSecond) = heartZoneSecond(heartBeat:heartBeat)
            return [
                BarData(name: "\(heartRate.zone5)", time: zone5/allSecond * 100, color: Color(.zone5Color)),
                BarData(name: "\(heartRate.zone4)", time: zone4/allSecond * 100, color: Color(.zone4Color)),
                BarData(name: "\(heartRate.zone3)", time: zone3/allSecond * 100, color: Color(.zone3Color)),
                BarData(name: "\(heartRate.zone2)", time: zone2/allSecond * 100, color: Color(.zone2Color)),
                BarData(name: "\(heartRate.zone1)", time: zone1/allSecond * 100, color: Color(.zone1Color))
            ]
        }
        return []
    }
    
    func paceZoneSecond(routes:[RouteNode]) -> (Double,Double,Double,Double,Double,Double) {
        var (zone5,zone4,zone3,zone2,zone1,allSecond) = (0.0,0.0,0.0,0.0,0.0,0.0)
        let filterdRoute = routes.filter { route in
            let value = 1.0/(route.location.speed * 60 / 1000)
            return value < (minPace?.doubleValue ?? 0.0) && value > (maxPace?.doubleValue ?? 0.0)
        }

        for (current,next) in zip(filterdRoute,filterdRoute.dropFirst()) {
            let second = next.date.timeIntervalSince1970 -  current.date.timeIntervalSince1970
            let value:Int16 = Int16(1.0/(current.location.speed / 1000))
            
            if value > paceZone.zone1 {
                zone1 += second
            } else if value > paceZone.zone2 {
                zone2 += second
            } else if value > paceZone.zone3 {
                zone3 += second
            } else if value > paceZone.zone4 {
                zone4 += second
            } else {
                zone5 += second
            }
            allSecond += second
        }
        return (zone5,zone4,zone3,zone2,zone1,allSecond)
    }
    
    func paceChartData() -> [BarData] {
        if let routes = routes {
            let (zone5,zone4,zone3,zone2,zone1,allSecond) = paceZoneSecond(routes:routes)
            return [
                BarData(name: paceZone.formatZone(zone: 5), time: zone5/allSecond * 100, color: Color(.zone5Color)),
                BarData(name: paceZone.formatZone(zone: 4), time: zone4/allSecond * 100, color: Color(.zone4Color)),
                BarData(name: paceZone.formatZone(zone: 3), time: zone3/allSecond * 100, color: Color(.zone3Color)),
                BarData(name: paceZone.formatZone(zone: 2), time: zone2/allSecond * 100, color: Color(.zone2Color)),
                BarData(name: paceZone.formatZone(zone: 1), time: zone1/allSecond * 100, color: Color(.zone1Color))
            ]
        }
        return []
    }
    
    func distance(from:Date, to:Date) -> Double {
        guard let routeNodes = routes else { return 0.0 }
        guard routeNodes.count > 0 else { return 0.0 }
        
        var firstNode:RouteNode?
        var lastNode:RouteNode?
        
        for (current,next) in zip(routeNodes,routeNodes.dropFirst()) {
            if(current.date < from && next.date >= from) {
                firstNode = current
            }
            
            if(current.date < to && next.date >= to) {
                lastNode = next
            }
        }
        
        if firstNode == nil && lastNode == nil {
            return 0.0
        }
        
        let first = firstNode ?? routeNodes.first!
        let last = lastNode ?? routeNodes.last!
        
        guard first != last else { return 0.0 }
        
        let firstIndex = routeNodes.firstIndex(of: first)!
        let lastIndex = routeNodes.firstIndex(of: last)!
        
        
        let slice = routeNodes[firstIndex...lastIndex]
        
        guard slice.count >= 2 else { return 0.0 }
        
        var distance = 0.0
        
        if(slice.count > 2) {
            let firstTwo = slice.prefix(2)
            let distanceSeg = firstTwo.last!.location.distance(from: firstTwo.first!.location)
            let fullSecond = firstTwo.last!.date.timeIntervalSince(firstTwo.first!.date)
            let startSecond = firstTwo.last!.date.timeIntervalSince(from)
            let startSeg = distanceSeg * (startSecond/fullSecond)
            distance += startSeg

            for (current,next) in zip(slice.dropFirst().dropLast(2),slice.dropFirst(2)) {
                distance += next.location.distance(from: current.location)
            }
            
            let lastTwo = slice.suffix(2)
            let distanceSegLast = lastTwo.last!.location.distance(from: lastTwo.first!.location)
            let fullSecondLast = lastTwo.last!.date.timeIntervalSince(lastTwo.first!.date)
            let lastSecond = to.timeIntervalSince(lastTwo.first!.date)
            let endSeg = distanceSegLast * (lastSecond/fullSecondLast)
            distance += endSeg
        } else { //区间点在两个之间
            let firstTwo = slice.prefix(2)
            let distanceSeg = firstTwo.last!.location.distance(from: firstTwo.first!.location)
            let fullSecond = firstTwo.last!.date.timeIntervalSince(firstTwo.first!.date)
            
            let firstSecond = from.timeIntervalSince(firstTwo.first!.date)
            let secondSecond = to.timeIntervalSince(firstTwo.first!.date)
            
            distance = distanceSeg * ((secondSecond - firstSecond)/fullSecond)
        }
        
        return distance
    }
    
    func zonePace() -> [ZonePace] {
        if let heartPace = heartPace {
            return heartPace
        }
        let  zoneDict:[ZonePace] = [
            ZonePace(second:0.0, distance:0.0),
            ZonePace(second:0.0, distance:0.0),
            ZonePace(second:0.0, distance:0.0),
            ZonePace(second:0.0, distance:0.0),
            ZonePace(second:0.0, distance:0.0)
        ]
        guard let heartBeat = heartbeat else { return zoneDict }
        
        var flag = heartBeat.first!
        for (_,heart) in heartBeat.dropFirst().enumerated() {
            if heartBeatZone(beat: heart) != heartBeatZone(beat: flag) {
                let zoneSecond = heart.date.timeIntervalSince(flag.date)
                let distacne = distance(from: flag.date, to: heart.date)
                let zone = heartBeatZone(beat: flag)
                zoneDict[zone.rawValue].second += zoneSecond
                zoneDict[zone.rawValue].distance += distacne
                flag = heart
            }
        }
        let last = heartBeat.last!
        if(last != flag) {
            let zoneSecond = last.date.timeIntervalSince(flag.date)
            let distacne = distance(from: flag.date, to: last.date)
            let zone = heartBeatZone(beat: flag)
            zoneDict[zone.rawValue].second += zoneSecond
            zoneDict[zone.rawValue].distance += distacne
        }
//        zoneDict.forEach { paceZone in
//            print("\(formatPace(minite: paceZone.paceMinite()))")
//        }
        heartPace = zoneDict
        try? self.managedObjectContext?.save()
        return zoneDict
    }
    
    func heartBeatZone(beat:DiscreateHKQuanty) -> Zone {
        let value = Int16(beat.value)
        if value >= heartRate.zone5 {
            return .zone5
        } else if value >= heartRate.zone4 {
            return .zone4
        } else if value >= heartRate.zone3 {
            return .zone3
        } else if value >= heartRate.zone2 {
            return .zone2
        } else {
            return .zone1
        }
    }
}

