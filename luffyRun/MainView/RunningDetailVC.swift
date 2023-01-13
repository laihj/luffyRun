//
//  RunningDetailVC.swift
//  luffyRun
//
//  Created by laihj on 2022/10/13.
//

import UIKit
import HealthKit
import Charts
import SnapKit
import SwiftUI

class RunningDetailVC: UIViewController {
    
    fileprivate var observer: ManagedObjectObserver?
    var barDatas:[BarData]?
    
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
        self.calHeartRate()
        self.setupViews()
        self.calPace()
        // Do any additional setup after loading the view.
    }
    
    func calHeartRate() {
        if let heartBeat = record.heartbeat {
            var (zone5,zone4,zone3,zone2,zone1) = (0.0,0.0,0.0,0.0,0.0)
            var allSecond = 0.0
            for (current,next) in zip(heartBeat,heartBeat.dropFirst()) {
                let second = next.date.timeIntervalSince1970 -  current.date.timeIntervalSince1970
                let value = Int(current.value)
                if value >= record.heartRate.zone5 {
                    zone5 += second
                } else if value >= record.heartRate.zone4 {
                    zone4 += second
                } else if value >= record.heartRate.zone3 {
                    zone3 += second
                } else if value >= record.heartRate.zone2 {
                    zone2 += second
                } else {
                    zone1 += second
                }
                allSecond += second
            }
            barDatas = [
                BarData(name: ">\(record.heartRate.zone5)", time: zone5/allSecond * 100, color: .purple),
                BarData(name: "\(record.heartRate.zone4)~\(record.heartRate.zone5)", time: zone4/allSecond * 100, color: .red),
                BarData(name: "\(record.heartRate.zone3)~\(record.heartRate.zone4)", time: zone3/allSecond * 100, color: .blue),
                BarData(name: "\(record.heartRate.zone2)~\(record.heartRate.zone3)", time: zone2/allSecond * 100, color: .yellow),
                BarData(name: "<\(record.heartRate.zone2)", time: zone1/allSecond * 100, color: .green)
            ]
        }
    }
    
    func calPace() {
        if let routes = record.routes {
            var (zone5,zone4,zone3,zone2,zone1) = (0.0,0.0,0.0,0.0,0.0)
            var allSecond = 0.0
            
            var route5s = [RouteNode]()
            for (index,route) in routes.enumerated() {
                if(index % 10 == 0) {
                    route5s.append(route)
                }
            }

            for (current,next) in zip(route5s,route5s.dropFirst()) {
                let second = (next.date.timeIntervalSince1970 -  current.date.timeIntervalSince1970) / 60.0
                let distance = current.location.distance(from: next.location) / 1000.0
                let pace = second/distance
                print(formatPace(minite: pace))
//s                print(current.date)
                
                let value = 1.0/(current.location.speed * 60 / 1000)
                print(current.location.speedAccuracy)
                
                
                
//                if value > record.heartRate.zone5 {
//                    zone5 += second
//                } else if value > record.heartRate.zone4 {
//                    zone4 += second
//                } else if value > record.heartRate.zone3 {
//                    zone3 += second
//                } else if value > record.heartRate.zone2 {
//                    zone2 += second
//                } else {
//                    zone1 += second
//                }
                allSecond += second
            }
        }
    }
    
    func setupViews() {
        let chart = SwiftChart(record: record, barDatas:barDatas)
        let hostingContrller = UIHostingController(rootView:chart)
        self.addChild(hostingContrller)
        self.view.addSubview(hostingContrller.view)
        hostingContrller.view.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        chart.barDatas = barDatas
        
        self.updateViews()
    }
    
    func updateViews () {
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
    }

}
