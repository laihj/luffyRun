//
//  ActivityListVC.swift
//  luffyRun
//
//  Created by laihj on 2022/9/22.
//

import UIKit
import HealthKit

class ActivityListVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonclick() {
        self.authorizeHealthKit { (success, error) in
            self.readWorkouts()
        }
    }
    
    func readWorkouts () {
        self.loadPrancerciseWorkouts { workouts, error in
            let workout = workouts?[1];
            print(workout?.totalDistance)
            
        }
    }
    
    func loadPrancerciseWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        let workoutPredication = HKQuery.predicateForWorkouts(with: .running)
        let  sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: workoutPredication, limit: 0, sortDescriptors: [sortDescriptor]) { query, samples, error in
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
        let healthKitTypesToWrite: Set<HKSampleType> = [HKObjectType.workoutType()]
        
        let healthKitTypesToRead: Set<HKSampleType> = [HKObjectType.workoutType()]
        
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToRead, read: healthKitTypesToWrite) { (success, error) in
            completion(success, error)
        }
    }
}

extension ActivityListVC: UITableViewDelegate {
    
}

extension ActivityListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LRRunningCell", for: indexPath) as! LRRunningRecordCell
        cell.label?.text = "running"
        return cell;
    }
}
