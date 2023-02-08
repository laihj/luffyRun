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
    
    var lastRecord:Record?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action:#selector(deleteRecord(sender:)))
        self.setupViews()
        // Do any additional setup after loading the view.
    }
    

    
    func setupViews() {
        let chart = SwiftChart(record: record, lastRecord: lastRecord)
        let hostingContrller = UIHostingController(rootView:chart)
        self.addChild(hostingContrller)
        self.view.addSubview(hostingContrller.view)
        hostingContrller.view.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
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
