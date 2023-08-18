//
//  SegView.swift
//  luffyRun
//
//  Created by laihj on 2023/8/7.
//

import UIKit

class SegView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.backgroundColor = UIColor.yellow
        self.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
    }
    
//    var segData:Array?
}
