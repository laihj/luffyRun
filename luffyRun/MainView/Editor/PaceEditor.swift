//
//  PaceEditor.swift
//  luffyRun
//
//  Created by laihj on 2023/3/20.
//

import UIKit
import CoreData

class PaceEditor: UIViewController {
    var context:NSManagedObjectContext?
    lazy var paceLabel:[UILabel] = [UILabel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "配速区间"
        
        let paceRate = PaceZone.lastedPaceZone(in: context!)
        
        self.setupViews()
        for (index,label) in paceLabel.enumerated() {
            label.text = paceRate?.formatZone(zone:5 - index)
        }
    }
    
    func setupViews() {
        let colorPaceView = UIStackView()
        colorPaceView.axis = .vertical
        colorPaceView.distribution = .fillEqually
        self.view.addSubview(colorPaceView)
        colorPaceView.layer.cornerRadius = 10;
        colorPaceView.layer.masksToBounds = true
        colorPaceView.backgroundColor = .green
        colorPaceView.snp.makeConstraints { make in
            make.width.equalTo(80);
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
//            make.left.equalTo(20)
        }
        
        let zoneColor:[UIColor] = [.zone5Color,.zone4Color,.zone3Color,.zone2Color,.zone1Color];
        let zoneTitle:[String] = ["zone5","zone4","zone3","zone2","zone1"];
        for (index,color) in zoneColor.enumerated() {
            let view = UIView()
            view.backgroundColor = color
            
            let title = UILabel()
            title.textColor = .white
            title.font = UIFont.boldSystemFont(ofSize: 14)
            title.textAlignment = .center
            title.text = zoneTitle[index]
            view.addSubview(title)
            title.snp.makeConstraints { make in
                make.edges.equalTo(0)
            }
            
            colorPaceView.addArrangedSubview(view)
        }
        
        let labelView = UIStackView()
        labelView.axis = .vertical
        labelView.distribution = .fillEqually
        labelView.backgroundColor = .clear
        view.addSubview(labelView);
        labelView.snp.makeConstraints { make in
            make.left.equalTo(colorPaceView.snp_rightMargin).offset(30)
            make.centerY.equalTo(colorPaceView)
            make.height.equalTo(colorPaceView).multipliedBy(0.8)
            make.width.equalTo(100);
        };
        
        for _ in 0...3 {
            let title = UILabel()
            title.textColor = .gray
            title.font = UIFont.boldSystemFont(ofSize: 24)
            title.textAlignment = .left
            title.text = "5:40"
            labelView.addArrangedSubview(title)
            paceLabel.append(title)
        }
        
        let lineView = UIStackView()
        lineView.axis = .vertical
        lineView.distribution = .equalSpacing
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerY.equalTo(colorPaceView)
            make.left.equalTo(colorPaceView.snp_rightMargin).offset(3)
            make.right.equalTo(labelView.snp_leftMargin).offset(-2)
            make.height.equalTo(colorPaceView).multipliedBy(0.6)
            make.centerX.equalTo(view)
        }
        
        for _ in 0...3 {
            let line = UIView()
            line.backgroundColor = .gray
            line.snp.makeConstraints { make in
                make.height.equalTo(1)
            }
            lineView.addArrangedSubview(line)
        }
        
    }
    

}
