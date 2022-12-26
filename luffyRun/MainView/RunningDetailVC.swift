//
//  RunningDetailVC.swift
//  luffyRun
//
//  Created by laihj on 2022/10/13.
//

import UIKit
import HealthKit

class RunningDetailVC: UIViewController {
    
    var workout:HKWorkout?
    
    fileprivate var observer: ManagedObjectObserver?
    
    var record:Record! {
        didSet {
            observer = ManagedObjectObserver(object: record, changeHandler: { [weak self] type in
                guard type == .delete else { return }
                _ = self?.navigationController?.popViewController(animated: true)
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action:#selector(deleteRecord(sender:)))

        // Do any additional setup after loading the view.
    }
    
    @objc
    func deleteRecord(sender: UIBarButtonItem) {
        record.managedObjectContext?.performChanges(block: {
            self.record.managedObjectContext?.delete(self.record)
        })
        print("delete mode")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
        let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        
        if let workout = self.workout {
            // Create the workout predicate.
            let forWorkout = HKQuery.predicateForObjects(from: workout)
            print(workout.startDate);
            print(workout.endDate);
            
            // Create the heart-rate descriptor.
            let heartRateDescriptor = HKQueryDescriptor(sampleType: HKSampleType.quantityType(forIdentifier:.heartRate)! ,
                                                        predicate: forWorkout)
            
            // Create the query.
            let heartRateQuery = HKSampleQuery(queryDescriptors: [heartRateDescriptor],
                                               limit: HKObjectQueryNoLimit)
            { query, samples, error in
                // Process the samples.
                guard let samples = samples else {
                    // Handle the error.
                    fatalError("*** An error occurred: \(error!.localizedDescription) ***")
                }
                
                // Iterate over all the samples.
                for sample in samples {
                    
                    guard let sample = sample as? HKDiscreteQuantitySample else {
                        fatalError("*** Unexpected Sample Type ***")
                    }
                    
                    // Check to see if the sample is a series.
                    if sample.count == 1 {
                        // This is a single sample.
                        // Use the sample.
                        print(sample.mostRecentQuantity.doubleValue(for: heartRateUnit));
                        print(sample.mostRecentQuantityDateInterval)

                    }
                    else {
                        // This is a series.
                        // Get the detailed items for the series.
                        self.myGetDetailedItems(sample:sample)
                    }
                }
            }
            
            // Run  the query.
            HKHealthStore().execute(heartRateQuery)
        }
        
        if let workout = self.workout {
            let runningObjectQuery = HKQuery.predicateForObjects(from: workout)
            let heartQuery = HKAnchoredObjectQuery(type: HKSeriesType.heartbeat(), predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
                guard error == nil else {
                    // Handle any errors here.
                    fatalError("The initial query failed.")
                }
            }

            let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in

                guard error == nil else {
                    // Handle any errors here.
                    fatalError("The initial query failed.")
                }

                if let workoutroute = samples?.first {

                    let query = HKWorkoutRouteQuery(route: workoutroute as! HKWorkoutRoute) { query, locations, done, error in
                        print(locations);
                    }
                    HKHealthStore().execute(query)
                }
                // Process the initial route data here.
            }

            routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in

                guard error == nil else {
                    // Handle any errors here.
                    fatalError("The update failed.")
                }

                // Process updates or additions here.
            }


            HKHealthStore().execute(routeQuery)
            
        }
//
    }
    

    func myGetDetailedItems(sample:HKDiscreteQuantitySample) {
        let inSeriesSample = HKQuery.predicateForObject(with: sample.uuid)

        // Create the query.
        let detailQuery = HKQuantitySeriesSampleQuery(quantityType: HKSampleType.quantityType(forIdentifier:.heartRate)!,
                                                      predicate: inSeriesSample)
        { query, quantity, dateInterval, HKSample, done, error in
            
            guard let quantity = quantity, let dateInterval = dateInterval else {
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
            }
            
            // Use the data.
            print("\(quantity.doubleValue(for: HKUnit(from: "count/min"))): \(dateInterval)");
        }

        // Run the query.
        HKHealthStore().execute(detailQuery)
        
    }

}
