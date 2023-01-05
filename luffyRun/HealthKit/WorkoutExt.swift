//
//  WorkoutExt.swift
//  luffyRun
//
//  Created by laihj on 2023/1/5.
//

import Foundation
import HealthKit


extension HKWorkout {
    func sumQuantityFor(_ identifier:HKQuantityTypeIdentifier, unit:HKUnit) -> Double? {
        let statistics = self.statistics(for: HKQuantityType(identifier))
        let quantity =  statistics?.sumQuantity()
        let value = quantity?.doubleValue(for: unit)
        return value
    }
    
    func averageQuantityFor(_ identifier:HKQuantityTypeIdentifier, unit:HKUnit) -> Double? {
        let statistics = self.statistics(for: HKQuantityType(identifier))
        let quantity =  statistics?.averageQuantity()
        let value = quantity?.doubleValue(for: unit)
        return value
    }
    
    func route(completion: @escaping ([RouteNode])->()) {
        let runningObjectQuery = HKQuery.predicateForObjects(from: self)

        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in

            guard error == nil else {
                fatalError("The initial query failed.")
            }
            
            var routes = Array<RouteNode>()

            if let workoutroute = samples?.first {
                let query = HKWorkoutRouteQuery(route: workoutroute as! HKWorkoutRoute) { query, locations, done, error in
                    if let locas = locations {
                        for location in locas {
                            let route = RouteNode(location: location, date: location.timestamp)
                            routes.append(route)
                        }
                    }
                    if(done) {
                        completion(routes)
                    }
                }
                HKHealthStore().execute(query)
            }
        }

        routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in
            guard error == nil else {
                fatalError("The update failed.")
            }
        }
        HKHealthStore().execute(routeQuery)
    }
    
    func heartRate(completion: @escaping ([HeartBeat])->()) {
        let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let forWorkout = HKQuery.predicateForObjects(from: self)
        let heartRateDescriptor = HKQueryDescriptor(sampleType: HKSampleType.quantityType(forIdentifier:.heartRate)! ,
                                                    predicate: forWorkout)
        
        // Create the query.
        let heartRateQuery = HKSampleQuery(queryDescriptors: [heartRateDescriptor],
                                           limit: HKObjectQueryNoLimit)
        { query, samples, error in
            // Process the samples.
            guard let samples = samples else {
                // Handle the error.
                completion([])
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
                
            }
            
            var heartbeat = Array<HeartBeat>()
            // Iterate over all the samples.
            for sample in samples {
                
                guard let sample = sample as? HKDiscreteQuantitySample else {
                    fatalError("*** Unexpected Sample Type ***")
                }
                
                if sample.count == 1 {
                    let recordHeartRate:HeartBeat = HeartBeat(sample: sample, unit: heartRateUnit)
                    heartbeat.append(recordHeartRate)
                }
            }
            completion(heartbeat)
        }
        
        // Run  the query.
        HKHealthStore().execute(heartRateQuery)
    }
    
    func power(completion: @escaping ([RouteNode])->()) {
        let stepUnit: HKUnit = HKUnit.watt()
        let forWorkout = HKQuery.predicateForObjects(from: self)
        let stepDescriptor = HKQueryDescriptor(sampleType: HKSampleType.quantityType(forIdentifier: .runningPower)!, predicate: forWorkout)
        let stepQuery = HKSampleQuery(queryDescriptors: [stepDescriptor], limit: HKObjectQueryNoLimit) { query, samples, error in
            guard let samples = samples else {

                completion([])
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
            }
            
            for sample in samples {
                
                guard let sample = sample as? HKDiscreteQuantitySample  else {
                    fatalError("*** Unexpected Sample Type ***")
                }
                
                if sample.count == 1 {
                    let step = sample.quantity.doubleValue(for: stepUnit)
                    print(step)

                }
            }
            
        }
        HKHealthStore().execute(stepQuery)
    }
    
    func stepCount(completion: @escaping ([RouteNode])->()) {
        let stepUnit: HKUnit = HKUnit.count()
        let forWorkout = HKQuery.predicateForObjects(from: self)
        let stepDescriptor = HKQueryDescriptor(sampleType: HKSampleType.quantityType(forIdentifier: .stepCount)!, predicate: forWorkout)
        let stepQuery = HKSampleQuery(queryDescriptors: [stepDescriptor], limit: HKObjectQueryNoLimit) { query, samples, error in
            guard let samples = samples else {
                // Handle the error.
                completion([])
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
            }
            
            for sample in samples {
                
                guard let sample = sample as? HKCumulativeQuantitySample  else {
                    fatalError("*** Unexpected Sample Type ***")
                }
                
                // Check to see if the sample is a series.
                if sample.count == 1 {
                    // This is a single sample.
                    // Use the sample.
                    let step = sample.sumQuantity.doubleValue(for: stepUnit)
                    print(step)

                }
            }
        }
        HKHealthStore().execute(stepQuery)
        
    }
}
