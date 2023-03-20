//
//  ShadowView.swift
//  luffyRun
//
//  Created by laihj on 2023/3/17.
//

import UIKit

class ShadowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.layer.cornerRadius = 10;
        self.layer.shadowColor = UIColor(hexString: "#000000").cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 4
    }
}
