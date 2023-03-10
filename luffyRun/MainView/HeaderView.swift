//
//  HeaderView.swift
//  luffyRun
//
//  Created by laihj on 2023/1/5.
//

import UIKit
import SwiftUI

struct headerViewData {
    var times:String
    var distance:String
    var duration:String
    var pace:String
    
    init(times: String, distance: String, duration: String, pace: String) {
        self.times = times
        self.distance = distance
        self.duration = duration
        self.pace = pace
    }
    
    init(records:[Record]) {
        self.times = "\(records.count)"
        
        let distance = records.reduce(0.0) { result, record in
            return result + (record.distance?.doubleValue ?? 0.0)
        }
        self.distance = String(format: "%.2fkm", distance/1000.0)
        
        let duration = records.reduce(0.0) { result, record in
            if let endDate = record.endDate {
                return result + (endDate.timeIntervalSince1970 - record.startDate.timeIntervalSince1970)
            } else {
                return result + 0.0
            }
            
        }
    
        self.duration = formatTime(seconds: duration)
        if(distance > 0) {
            let averagePace = (duration/60.0) / (distance/1000.0)
            self.pace = formatPace(minite: averagePace)
        } else {
            self.pace = formatPace(minite: 0)
        }

    }
}


class HeaderView: UIView {
    @IBOutlet var times:UILabel?
    @IBOutlet var distance:UILabel?
    @IBOutlet var duration:UILabel?
    @IBOutlet var pace:UILabel?
    @IBOutlet var dataBackgroundView:UIView?
    
    
    lazy var scrollView = UIScrollView(frame: CGRect.zero)
    lazy var runningView = RunningView(frame:CGRect.zero)
    lazy var statsView = UIView(frame: CGRect.zero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 10;
        self.insertSubview(bgView, belowSubview: dataBackgroundView!)
        bgView.layer.shadowColor = UIColor(hexString: "#000000").cgColor
        bgView.layer.shadowOffset = CGSize(width: 2, height: 2)
        bgView.layer.shadowOpacity = 0.1
        bgView.layer.shadowRadius = 4
        bgView.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(-6)
        }
        
        bgView.addSubview(scrollView)

        scrollView.isPagingEnabled = true
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.bottom.equalTo(-10)
        }
        
        scrollView.addSubview(runningView)
        
        runningView.layer.cornerRadius = 10;

        
        runningView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalTo(scrollView.snp.width)
            make.height.equalTo(scrollView.snp.height)
            make.bottom.equalTo(0)
        }
        
        scrollView.addSubview(statsView)
        statsView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(runningView.snp.right)
            make.width.equalTo(scrollView.snp.width)
            make.height.equalTo(scrollView.snp.height)
            make.bottom.equalTo(0)
            make.right.equalTo(0)
        }
        
        if let dataBackgroundView = dataBackgroundView {
            dataBackgroundView.backgroundColor = UIColor.clear
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.white.withAlphaComponent(0.8).cgColor, UIColor.white.withAlphaComponent(0.0).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.locations = [0, 1]
            gradientLayer.frame = dataBackgroundView.bounds
            dataBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    
    var stats:headerViewData? {
        willSet(newStats) {
            if let stats = newStats {
                times?.text = stats.times
                distance?.text = stats.distance
                duration?.text = stats.duration
                pace?.text = stats.pace
            }
        }
    }
    
    var lastRecords:[Record]? {
        willSet(newDatas) {
            if let records = newDatas {
                let swiftUIViewController = UIHostingController(rootView: HeartZonePaceStats(records: records))
                statsView.addSubview(swiftUIViewController.view)
                swiftUIViewController.view.snp.makeConstraints { make in
                    make.edges.equalTo(0)
                }
            }
        }
    }
    
    var dayRunningDatas:[DayRunningData]? {
        willSet(newDatas) {
            if let datas = newDatas {
                runningView.dayRunningDatas = datas
            }
        }
    }
}
