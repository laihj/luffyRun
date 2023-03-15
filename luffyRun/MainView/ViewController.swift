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
    
    lazy var scrollView = UIScrollView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
}

