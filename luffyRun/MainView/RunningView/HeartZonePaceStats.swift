//
//  HeartZonePaceStats.swift
//  luffyRun
//
//  Created by laihj on 2023/1/31.
//

import SwiftUI
import Charts

struct HeartZonePaceStats: View {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = .current
        return formatter
    }()
    
    var records:[Record?]
    var body: some View {
        VStack {
            Text("Hello luffy")
//            Chart {
//                ForEach(records, id: \.?.objectID) { record in
//                    let zonePace = record?.zonePace()
//                    let zone1pace = zonePace?[Zone.zone1]?.paceMinite() ?? 0.0
//                    LineMark(
//                        x: .value("Week Day", dateFormatter.string(from: record!.startDate)),
//                        y: .value("zone1", zone1pace),
//                        series: .value("zone1", "A")
//                    ).foregroundStyle(.green)
//
//                    let zone2pace = zonePace?[Zone.zone2]?.paceMinite() ?? 0.0
//                    LineMark(
//                        x: .value("Week Day", dateFormatter.string(from: record!.startDate)),
//                        y: .value("zone2", zone2pace),
//                        series: .value("zone2", "B")
//                    ).foregroundStyle(.yellow)
//
//                    let zone3pace = zonePace?[Zone.zone3]?.paceMinite() ?? 0.0
//                    LineMark(
//                        x: .value("Week Day", dateFormatter.string(from: record!.startDate)),
//                        y: .value("zone3", zone3pace),
//                        series: .value("zone3", "C")
//                    ).foregroundStyle(.blue)
//
//                    let zone4pace = zonePace?[Zone.zone4]?.paceMinite() ?? 0.0
//                    LineMark(
//                        x: .value("Week Day", dateFormatter.string(from: record!.startDate)),
//                        y: .value("zone4", zone4pace),
//                        series: .value("zone4", "D")
//                    ).foregroundStyle(.red)
//
//                    let zone5pace = zonePace?[Zone.zone5]?.paceMinite() ?? 0.0
//                    LineMark(
//                        x: .value("Week Day", dateFormatter.string(from: record!.startDate)),
//                        y: .value("zone5", zone5pace),
//                        series: .value("zone5", "F")
//                    ).foregroundStyle(.purple)
//                }
//            }.frame(height: 80)
//                .chartXAxis(.hidden)
        }
    }
    
}

struct HeartZonePaceStats_Previews: PreviewProvider {
    static var previews: some View {
        HeartZonePaceStats(records: [])
    }
}
