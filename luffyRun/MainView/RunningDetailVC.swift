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
    
    lazy var label = UILabel()
    
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
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func calHeartRate() {
        if let heartBeat = record.heartbeat {
            var (zone5,zone4,zone3,zone2,zone1) = (0.0,0.0,0.0,0.0,0.0)
            var allSecond = 0.0
            for (current,next) in zip(heartBeat,heartBeat.dropFirst()) {
                let second = next.date.timeIntervalSince1970 -  current.date.timeIntervalSince1970
                let value = Int(current.value)
                if value > record.heartRate.zone5 {
                    zone5 += second
                } else if value > record.heartRate.zone4 {
                    zone4 += second
                } else if value > record.heartRate.zone3 {
                    zone3 += second
                } else if value > record.heartRate.zone2 {
                    zone2 += second
                } else {
                    zone1 += second
                }
                allSecond += second
            }
            barDatas = [
                BarData(name: "zone5", time: zone5/allSecond * 100, color: .purple),
                BarData(name: "zone4", time: zone4/allSecond * 100, color: .red),
                BarData(name: "zone3", time: zone3/allSecond * 100, color: .blue),
                BarData(name: "zone2", time: zone2/allSecond * 100, color: .yellow),
                BarData(name: "zone1", time: zone1/allSecond * 100, color: .green)
            ]
        }
    }
    
    func setupViews() {
        label = UILabel()
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalTo(self.view)
        }
        
        let chart = SwiftChart(barDatas:barDatas)
        let hostingContrller = UIHostingController(rootView:chart)
        self.addChild(hostingContrller)
        self.view.addSubview(hostingContrller.view)
        hostingContrller.view.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        chart.barDatas = barDatas
        
        self.updateViews()
        
    }
    
    func updateViews () {
        label.text = record.source
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
