//
//  ActivityListVC.swift
//  luffyRun
//
//  Created by laihj on 2022/9/22.
//

import UIKit
import HealthKit

class ActivityListVC: UIViewController {
    
    var workouts:[HKWorkout]?
    @IBOutlet var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.buttonclick()
    }
    
    @IBAction func buttonclick() {
        self.authorizeHealthKit { (success, error) in
            self.readWorkouts()
        }
    }
    
    func readWorkouts () {
        self.loadPrancerciseWorkouts { workouts, error in
            self.workouts = workouts
            let workout = self.workouts?.first;
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    func loadPrancerciseWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        
        
        let workoutPredication = HKQuery.predicateForWorkouts(with: .running)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
//        let compond = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredication,sourcePredicte])
        
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: workoutPredication, limit: 10, sortDescriptors: [sortDescriptor]) { query, samples, error in
            let samples = samples as? [HKWorkout]
            
            completion(samples, nil)
            
        }
        
        HKHealthStore().execute(query)
        

    }
    
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
                                                        HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        
        let healthKitTypesToRead: Set<HKSampleType> = [HKObjectType.workoutType(),
                                                       HKSeriesType.workoutRoute(),
                                                       HKSeriesType.heartbeat(),
                                                       HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                                       HKSeriesType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                                       HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToRead, read: healthKitTypesToWrite) { (success, error) in
            completion(success, error)
        }
    }
}

extension ActivityListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let workout = self.workouts?[indexPath.row] {
            let runningDetail = RunningDetailVC.init()
            runningDetail.workout = workout
            let statistics = workout.statistics(for: HKQuantityType(.distanceWalkingRunning))
            statistics?.averageQuantity()
            
            let speed = workout.statistics(for: HKQuantityType(.runningSpeed));
//            speed?.sumQuantity()?.doubleValue(for:.)
//            speed?.averageQuantity()
            let heart = workout.statistics(for: HKQuantityType(.heartRate));
            
            self.navigationController?.pushViewController(runningDetail, animated: true)
            HKUnit.minute()
        }
    }
    
}

extension ActivityListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let workouts = self.workouts {
            return workouts.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LRRunningCell", for: indexPath) as! LRRunningRecordCell
        if let workout = self.workouts?[indexPath.row] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            cell.label?.text = dateFormatter.string(from: workout.startDate)
            cell.sourceName?.text = workout.sourceRevision.source.name
            
            print(workout.totalDistance)
            print(workout.allStatistics)
//            print(workout.metadata)
//            print(workout.allStatistics)
//            print(workout.device)
            print(workout.sourceRevision.source.name)
            print("=======")

            
        }
        return cell;
    }
    

}
