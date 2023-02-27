//
//  DateExt.swift
//  luffyRun
//
//  Created by laihj on 2023/2/27.
//

import Foundation

extension Date {
    func string(format:String) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = .current
            return formatter
        }()
        return dateFormatter.string(from: self)
    }
}
