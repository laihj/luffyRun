//
//  LRRunningRecordCell.swift
//  luffyRun
//
//  Created by laihj on 2022/9/23.
//

import UIKit

class LRRunningRecordCell: UITableViewCell {
    
    @IBOutlet var label:UILabel?
    @IBOutlet var sourceName:UILabel?

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
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    formatter.formattingContext = .standalone
    return formatter
}()


extension LRRunningRecordCell {
    func configure(for record: Record) {
        label!.text = dateFormatter.string(from: record.startDate)
        sourceName?.text = record.source
    }
}
