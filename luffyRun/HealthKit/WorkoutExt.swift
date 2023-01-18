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
    
    func averageQuantityFor(_ identifier:HKQuantityTypeIdentifier, unit:HKUnit) -> Double?{
        let statistics = self.statistics(for: HKQuantityType(identifier))
        let quantity =  statistics?.averageQuantity()
        let value = quantity?.doubleValue(for: unit)
        return value
    }
    
    func quantityFor(_ identifier:HKQuantityTypeIdentifier, unit:HKUnit) -> (Double,Double,Double)? {
        let statistics = self.statistics(for: HKQuantityType(identifier))
        let minQuantity = statistics?.minimumQuantity()
        let minValue = minQuantity?.doubleValue(for: unit)
        
        let quantity =  statistics?.averageQuantity()
        let avgValue = quantity?.doubleValue(for: unit)
        
        let maxQuantity = statistics?.maximumQuantity()
        let maxValue = maxQuantity?.doubleValue(for: unit)
        
        return (minValue ?? 0.0, avgValue ?? 0.0,maxValue ?? 0.0)
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
                    if(locations?.count == 0) {
                        fatalError("The initial query failed.")
                    }
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
            } else {
                print("not")
            }
        }

        routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in
            guard error == nil else {
                fatalError("The update failed.")
            }
        }
        HKHealthStore().execute(routeQuery)
    }

    func discreateQuanty(identifier:HKQuantityTypeIdentifier, unit:HKUnit, completion: @escaping ([DiscreateHKQuanty])->()) {
        let quantityType =  HKSampleType.quantityType(forIdentifier:identifier)!
        let forWorkout = HKQuery.predicateForObjects(from: self)
        let quantityDescriptor = HKQueryDescriptor(sampleType: quantityType,
                                                    predicate: forWorkout)
        
        // Create the query.
        let quantityQuery = HKSampleQuery(queryDescriptors: [quantityDescriptor],
                                           limit: HKObjectQueryNoLimit)
        { query, samples, error in
            // Process the samples.
            guard let samples = samples else {
                // Handle the error.
                completion([])
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
                
            }
            
            var quantyArray = Array<DiscreateHKQuanty>()
            // Iterate over all the samples.
            for sample in samples {
                
                guard let sample = sample as? HKDiscreteQuantitySample else {
                    fatalError("*** Unexpected Sample Type ***")
                }
                
                if sample.count == 1 {
                    let quantity:DiscreateHKQuanty = DiscreateHKQuanty(sample: sample, unit: unit)
                    quantyArray.append(quantity)
                }
            }
            completion(quantyArray)
        }
        
        // Run  the query.
        HKHealthStore().execute(quantityQuery)
    }
//    CumulativeQuantity
    func cumulativeQuantity(identifier:HKQuantityTypeIdentifier, unit:HKUnit, completion: @escaping ([CumulativeQuantity])->()) {
        let quantityType =  HKSampleType.quantityType(forIdentifier:identifier)!
        let forWorkout = HKQuery.predicateForObjects(from: self)
        let stepDescriptor = HKQueryDescriptor(sampleType: quantityType, predicate: forWorkout)
        let stepQuery = HKSampleQuery(queryDescriptors: [stepDescriptor], limit: HKObjectQueryNoLimit) { query, samples, error in
            
            guard let samples = samples else {
                completion([])
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
            }
            
            var quantyArray = Array<CumulativeQuantity>()
            
            for sample in samples {
                guard let sample = sample as? HKCumulativeQuantitySample  else {
                    fatalError("*** Unexpected Sample Type ***")
                }

                if sample.count == 1 {
                    let quantity:CumulativeQuantity = CumulativeQuantity(sample: sample, unit: unit)
                    quantyArray.append(quantity)
                }
            }
            completion(quantyArray)
        }
        HKHealthStore().execute(stepQuery)
    }
}
