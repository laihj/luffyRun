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
    lazy var stackView:UIStackView = {
        let view = UIStackView(frame: CGRect.zero)
        view.spacing = 8
        view.distribution = .equalSpacing
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    lazy var paceZoneView = ShadowView(frame: CGRect.zero)
    lazy var heartZoneView = ShadowView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        scrollView.addSubview(stackView);
        stackView.snp.makeConstraints { make in
            make.width.equalTo(self.view)
            make.edges.equalTo(0)
        }
        
        stackView.addArrangedSubview(paceZoneView)
        paceZoneView.backgroundColor = .white
        paceZoneView.snp.makeConstraints { make in
            make.width.equalTo(self.stackView).offset(-32);
            make.height.equalTo(100)
        };
        
        stackView.addArrangedSubview(heartZoneView)
        heartZoneView.backgroundColor = .white
        heartZoneView.snp.makeConstraints { make in
            make.width.equalTo(self.stackView).offset(-32);
            make.height.equalTo(100)
        };
    }
}

