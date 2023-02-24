//
//  HealthKitHelper.swift
//  luffyRun
//
//  Created by laihj on 2022/12/30.
//

import Foundation
import HealthKit

func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
    guard HKHealthStore.isHealthDataAvailable() else {
        completion(false, nil)
        return;
    }
    let healthKitTypesToWrite: Set<HKSampleType> = [HKObjectType.workoutType(),
                                                    HKSeriesType.workoutRoute(),
                                                    HKSeriesType.heartbeat(),
                                                    HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                                    HKSeriesType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                                    HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                                                    HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                                                    HKQuantityType.quantityType(forIdentifier: .runningPower)!,
                                                    HKQuantityType.quantityType(forIdentifier: .runningSpeed)!]
    
    let healthKitTypesToRead: Set<HKSampleType> = [HKObjectType.workoutType(),
                                                   HKSeriesType.workoutRoute(),
                                                   HKSeriesType.heartbeat(),
                                                   HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                                   HKSeriesType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                                   HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                                                   HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                                                   HKQuantityType.quantityType(forIdentifier: .runningPower)!,
                                                   HKQuantityType.quantityType(forIdentifier: .runningSpeed)!]
    
    HKHealthStore().requestAuthorization(toShare: healthKitTypesToRead, read: healthKitTypesToWrite) { (success, error) in
        completion(success, error)
    }
}

func loadPrancerciseWorkouts(startDate:Date,completion: @escaping ([HKWorkout]?, Error?) -> Void) {
    let workoutPredication = HKQuery.predicateForWorkouts(with: .running)
    let datePredication = HKQuery.predicateForSamples(withStart: startDate, end: Date())
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
    
    let compond = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredication,datePredication])
    let query = HKSampleQuery(sampleType: .workoutType(), predicate: compond, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
        let samples = samples as? [HKWorkout]
        
        completion(samples, nil)
    }
    HKHealthStore().execute(query)
}

func loadWorkoutWith(udid:UUID, completion: @escaping (HKWorkout?, Error?) -> Void) {
    let workoutPredication = HKQuery.predicateForWorkouts(with: .running)

    let predicate = HKQuery.predicateForObject(with: udid)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
    
    let compond = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredication,predicate])
    let query = HKSampleQuery(sampleType: .workoutType(), predicate: compond, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
        if let samples = samples as? [HKWorkout] {
            completion(samples.first,nil)
        } else {
            completion(nil, nil)
        }
    }
    HKHealthStore().execute(query)
}
