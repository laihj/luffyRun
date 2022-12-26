//
//  ViewController.swift
//  luffyRun
//
//  Created by laihj on 2022/9/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var context:NSManagedObjectContext?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
    }
    
    @IBAction func addHeartRate() {
        let manager = FileManager.default

        let urlForDocument = manager.urls(for: .documentDirectory, in:.userDomainMask)

        let url = urlForDocument[0] as URL

        print(url)
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        context = appDelegate.persistentContainer.viewContext
//        context?.performChanges(block: {
//            let  heartRate = HeartRate.insert(into: self.context!)
//            heartRate.rest = 46
//            heartRate.max = 184
//            heartRate.zone1 = 127
//            heartRate.zone2 = 148
//            heartRate.zone3 = 162
//            heartRate.zone4 = 167
//            heartRate.zone5 = 177
//        })
    }
}

