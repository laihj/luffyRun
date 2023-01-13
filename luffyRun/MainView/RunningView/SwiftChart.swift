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
    var record:Record?
    @State var barDatas:[BarData]?
    var body: some View {
        ScrollView {
            Spacer(minLength: 30)
            VStack {
                HStack(spacing: 16) {
                    let distanceKM = String(format: "%.2f", (record?.distance?.doubleValue ?? 0.00)/1000.0)
                    VStack(alignment: .trailing) {
                        Text("\(distanceKM)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("距离/km")
                    }
                    Spacer()
                    
                    let kCal = String(format: "%.0f", record?.kCal?.doubleValue ?? 0)
                    VStack(alignment: .trailing) {
                        Text("\(kCal)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("大卡")
                    }
                    Spacer()
                }
                Spacer(minLength: 10)
                
                HStack(spacing: 16) {
                    let pace = formatPace(minite: (record?.avaragePace?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(pace)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("平均配速")
                    }
                    Spacer()
                    
                    let length = String(format: "%.1f", record?.averageSLength?.doubleValue ?? 0.00)
                    VStack(alignment: .trailing) {
                        Text("\(length)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("平均步长")
                    }
                    Spacer()
                }
                Spacer(minLength: 10)
                
                HStack(spacing: 16) {
                    let heart = String(format: "%.0f", (record?.avarageHeart?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(heart)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("平均心率")
                    }
                    Spacer()
                    
                    let watt = String(format: "%.0f", (record?.avarageWatt?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(watt)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("平均功率")
                    }
                    Spacer()
                }
                Spacer(minLength: 10)
                Text("心率")
                Chart() {
                    ForEach(barDatas ?? [], id:\.id) { data in
                        BarMark(x: .value("time", data.time),
                                y: .value("name", data.name))
                        .foregroundStyle(data.color)
                    }
                }.frame(height: 240)
            }
        }

        
    }
}

struct SwiftChart_Previews: PreviewProvider {
    static var previews: some View {
        SwiftChart()
    }
}
