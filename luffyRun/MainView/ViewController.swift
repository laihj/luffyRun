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
    
    @objc func toPaceEditor(tap:UITapGestureRecognizer) {
        let paceEditor = PaceEditor()
        paceEditor.context = context
        self.navigationController?.pushViewController(paceEditor, animated: true)
    }
    
    @objc func toHeartRateEditor(tap:UITapGestureRecognizer) {
        let heartRateEditor = HeartRateEditor()
        heartRateEditor.context = context
        self.navigationController?.pushViewController(heartRateEditor, animated: true)
    }
    
    
    lazy var paceZoneView:ShadowView = {
        let shadowView = ShadowView(frame: CGRect.zero)
        let stackView = UIStackView(frame: CGRect.zero)
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        shadowView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(12)
        };
        
        let name = UILabel()
        stackView .addArrangedSubview(name)
        name.text = "配速区间"
        name.font = UIFont.systemFont(ofSize: 12)
        name.textColor = .gray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toPaceEditor(tap:)))
        shadowView.addGestureRecognizer(tap)
        return shadowView
    }()
    
    
    lazy var heartZoneView = {
        let shadowView = ShadowView(frame: CGRect.zero)
        let stackView = UIStackView(frame: CGRect.zero)
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        shadowView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(12)
        };
        
        let name = UILabel()
        stackView .addArrangedSubview(name)
        name.text = "心速区间"
        name.font = UIFont.systemFont(ofSize: 12)
        name.textColor = .gray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toHeartRateEditor(tap:)))
        shadowView.addGestureRecognizer(tap)
        return shadowView
    }()
    
}

