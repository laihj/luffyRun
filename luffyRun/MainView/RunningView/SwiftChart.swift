//
//  SwiftChart.swift
//  luffyRun
//
//  Created by laihj on 2023/1/12.
//

import SwiftUI
import Charts

struct BarData:Identifiable {
    let id = UUID()
    let name:String
    let time:Double
    let color:Color
}

struct SwiftChart: View {
    @State var barDatas:[BarData]?
    var body: some View {
        VStack {
            Text("心率")
            Chart() {
                ForEach(barDatas ?? [], id:\.id) { data in
                    BarMark(x: .value("name", data.name),
                            y: .value("time", data.time))
                    .foregroundStyle(data.color)
                }
            }
            
            Chart() {
                ForEach(barDatas ?? [], id:\.id) { data in
                    BarMark(x: .value("name", data.name),
                            y: .value("time", data.time))
                    .foregroundStyle(data.color)
                }
            }

        }
        
    }
}

struct SwiftChart_Previews: PreviewProvider {
    static var previews: some View {
        SwiftChart()
    }
}
