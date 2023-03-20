//
//  RunningView.swift
//  luffyRun
//
//  Created by laihj on 2023/1/10.
//

import UIKit

struct DayRunningData {
    let distance:Double
    let date:Date
    
    init(distance: Double, date: Date) {
        self.distance = distance
        self.date = date
    }
    
    init(records:[Record], date: Date) {
        let distance = records.reduce(0.0) { result, record in
            return result + (record.distance?.doubleValue ?? 0.0)
        }
        self.init(distance: distance, date: date)
    }
}

class RunningView: UIView {
    
    
    var dayRunningDatas:[DayRunningData]? {
        willSet(newDatas) {
            if let datas = newDatas {
                let dayBefore30 = Date().startOfDay.addOneDay.addingTimeInterval(-30 * 24 * 3600)
                for(data,view) in zip(datas, viewList) {
                    if(data.distance > 0) {
                        view.backgroundColor = UIColor.mePurple.withAlphaComponent(0.5 + data.distance/20000.0)
                    } else {
                        view.backgroundColor = .lightGray.withAlphaComponent(0.4)
                    }
                    
                    view.layer.borderWidth = (data.date.isSameDay(date: Date()) || data.date.isSameDay(date: dayBefore30)) ? 1.5 : 0.0
                    
                    if data.date.isSameDay(date: Date()) {
                        view.layer.borderColor = UIColor.red.cgColor
                    } else if data.date.isSameDay(date: dayBefore30) {
                        view.layer.borderColor = UIColor.green.cgColor
                    } else {
                        view.layer.borderColor = UIColor.clear.cgColor
                    }
                }
            }
        }
    }
    
    let column = 17
    
    lazy var viewList:[UIView] = {
        var list = [UIView]()
        for _ in 0...((column + 1) * 7 - 1)  {
            let littleView = UIView()
            littleView.backgroundColor = .lightGray.withAlphaComponent(0.4)
            littleView.layer.cornerRadius = 2.4
            littleView.layer.borderColor = UIColor.mePurple.cgColor
            littleView.layer.masksToBounds = true
            littleView.snp.makeConstraints { make in
                make.width.equalTo(littleView.snp.height)
            }
            list.append(littleView)
        }
        return list
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let outterStack = UIStackView()
        outterStack.axis = .horizontal
        outterStack.spacing = 3
        outterStack.distribution = .equalSpacing
        self.addSubview(outterStack)
        outterStack.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(0)
        }
        
        for i in 0...column {
            let columnStack = UIStackView()
            columnStack.axis = .vertical
            columnStack.spacing = 3
            columnStack.distribution = .fillEqually
            
            for j in (i*7)...(i*7+6) {
                columnStack.addArrangedSubview(self.viewList[j])
            }
            
            outterStack.addArrangedSubview(columnStack)
        }
    }
}

