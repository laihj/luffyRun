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
            let workout = workouts?[1];
            self.workouts = workouts
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
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
        if let workouts = self.workouts {
            return workouts.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LRRunningCell", for: indexPath) as! LRRunningRecordCell
        if let workout = self.workouts?[indexPath.row] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            cell.label?.text = dateFormatter.string(from: workout.startDate)
        }
        return cell;
    }
}
