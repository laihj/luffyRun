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
    var body: some View {
        ScrollView {
            Spacer(minLength: 30)
            VStack (spacing: 10){
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
                    let length = String(format: "%.1f", record?.averageSLength?.doubleValue ?? 0.00)
                    VStack(alignment: .trailing) {
                        Text("\(length)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("平均步长")
                    }
                    Spacer()
                }
                //配速
                HStack(spacing: 16) {
                    let minPace = formatPace(minite: (record?.minPace?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(minPace)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("最低")
                    }
                    Spacer()
                    
                    let pace = formatPace(minite: (record?.avaragePace?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(pace)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("平均")
                    }
                    Spacer()
                    
                    let maxPace = formatPace(minite: (record?.maxPace?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(maxPace)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("最高")
                    }
                    Spacer()
                }
                //心率
//                Text("心率")
                HStack(spacing: 16) {
                    let minHeart = String(format: "%.0f", (record?.minHeart?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(minHeart)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("最低")
                    }
                    Spacer()
                    
                    let heart = String(format: "%.0f", (record?.avarageHeart?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(heart)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("平均")
                    }
                    Spacer()
                    
                    let maxHeart = String(format: "%.0f", (record?.maxHeart?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(maxHeart)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("最高")
                    }
                    Spacer()
                }
                //功率
//                Text("功率")
                HStack(spacing: 16) {
                    let minWatt = String(format: "%.0f", (record?.minWatt?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(minWatt)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("最低")
                    }
                    Spacer()
                    
                    let watt = String(format: "%.0f", (record?.avarageWatt?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(watt)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("平均")
                    }
                    Spacer()
                    
                    let maxWatt = String(format: "%.0f", (record?.maxWatt?.doubleValue ?? 0.00))
                    VStack(alignment: .trailing) {
                        Text("\(maxWatt)")
                            .font(.system(size: 25,weight: .semibold))
                        Text("最高")
                    }
                    Spacer()
                }
                Spacer(minLength: 10)
                Group{
                    Text("心率区间")
                    Chart() {
                        ForEach(record?.heartRateChartData() ?? [], id:\.id) { data in
                            BarMark(x: .value("time", data.time),
                                    y: .value("name", data.name))
                            .foregroundStyle(data.color)
                        }
                    }.frame(height: 240)
                }
                Group{
                    Text("配速区间")
                    Chart() {
                        ForEach(record?.paceChartData() ?? [], id:\.id) { data in
                            BarMark(x: .value("time", data.time),
                                    y: .value("name", data.name))
                            .foregroundStyle(data.color)
                        }
                    }.frame(height: 240)
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
