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

class RunningDetailVC: UIViewController {
    
    fileprivate var observer: ManagedObjectObserver?
    
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
        self.setupViews()
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        label = UILabel()
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalTo(self.view)
        }
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
