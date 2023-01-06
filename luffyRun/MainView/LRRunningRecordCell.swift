//
//  LRRunningRecordCell.swift
//  luffyRun
//
//  Created by laihj on 2022/9/23.
//

import UIKit

class LRRunningRecordCell: UITableViewCell {
    
    @IBOutlet var distance:UILabel?
    @IBOutlet var heart:UILabel?
    @IBOutlet var pace:UILabel?
    @IBOutlet var power:UILabel?
    @IBOutlet var kcal:UILabel?
    @IBOutlet var time:UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    formatter.timeZone = .current
    return formatter
}()


extension LRRunningRecordCell {
    func configure(for record: Record) {
        if let totalDisatnce = record.distance {
            distance!.text = String(format: "%.2f", totalDisatnce.doubleValue/1000)
        }

        if let avarageHeart = record.avarageHeart {
            heart?.text = String(format: "%.0f", avarageHeart.doubleValue)
        }
        
        if let apower = record.avarageWatt {
            power?.text = String(format: "%.0f", apower.doubleValue)
        }
        
        if let akCal = record.kCal {
            kcal?.text = String(format: "%.0f", akCal.doubleValue)
        }
        
        if let aPace = record.avaragePace {
            pace?.text = formatPace(minite: aPace.doubleValue)
        }
        
        if let endDate = record.endDate {
            let formatTime = formatTime(seconds: endDate.timeIntervalSince1970 - record.startDate.timeIntervalSince1970)
            time?.text = "\(dateFormatter.string(from: record.startDate)) - \(formatTime)"
        }
        
    }
}
