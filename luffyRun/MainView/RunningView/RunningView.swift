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
                for (index, data) in datas.enumerated() {
                    if data.distance > 0 {
                        self.viewList[index].backgroundColor = .purple
                    }
                }
            }
        }
    }
    
    let column = 11
    
    lazy var viewList:[UIView] = {
        var list = [UIView]()
        for _ in 0...((column + 1) * 7 - 1)  {
            let littleView = UIView()
            littleView.backgroundColor = .lightGray.withAlphaComponent(0.4)
            littleView.layer.cornerRadius = 2.4
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
            make.right.top.bottom.equalTo(0)
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
