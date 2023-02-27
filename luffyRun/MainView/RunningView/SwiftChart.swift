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
    var lastRecord:Record?
    var body: some View {
        ScrollView {
            VStack (spacing: 10){
                if let record = record {
                    HStack {
                        Text("\(record.startDate.string(format: "yyyy-MM-dd HH:mm"))")
                            .font(.system(size:14))
                            .foregroundColor(.gray)
                        Spacer()
                        if let temp = record.temperature,let hud = record.humidity {
                            if hud.doubleValue > 0 {
                                let weather = String(format: "%.0f°c  %.0f%%", temp.doubleValue,hud.doubleValue)
                                Text("\(weather)")
                                    .font(.system(size:14))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                VStack(alignment: .center) {
                    HStack {
                        let distanceKM = String(format: "%.2f", (record?.distance?.doubleValue ?? 0.00)/1000.0)
                        VStack(alignment: .center) {
                            Text("\(distanceKM)")
                                .font(.system(size: 28,weight: .semibold))
                            Text("距离/km")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()

                        let kCal = String(format: "%.0f", record?.kCal?.doubleValue ?? 0)
                        VStack(alignment: .center) {
                            Text("\(kCal)")
                                .font(.system(size: 28,weight: .semibold))
                            Text("大卡")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        let length = String(format: "%.1f", record?.averageSLength?.doubleValue ?? 0.00)
                        VStack(alignment: .center) {
                            Text("\(length)")
                                .font(.system(size: 28,weight: .semibold))
                            Text("平均步长")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                    }
                    Divider()
                    HStack {
                        let stpes = String(format: "%.0f", record?.step?.doubleValue ?? 0.00)
                        VStack(alignment: .center) {
                            Text("\(stpes)")
                                .font(.system(size: 28,weight: .semibold))
                            Text("步数")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()

                        let watt = String(format: "%.0f", (record?.avarageWatt?.doubleValue ?? 0.00))
                        VStack(alignment: .center) {
                            Text("\(watt)")
                                .font(.system(size: 28,weight: .semibold))
                            Text("平均功率")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        let length = String(format: "%.1f", record?.mets?.doubleValue ?? 0.00)
                        VStack(alignment: .center) {
                            Text("\(length)")
                                .font(.system(size: 28,weight: .semibold))
                            Text("代谢当量")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                    }

                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 4, y: 4)
                )
                //配速
                VStack {
                    Text("配速")
                        .font(.system(size:16))
                    HStack(spacing: 16) {
//                        let minPace = formatPace(minite: (record?.minPace?.doubleValue ?? 0.00))
//                        VStack(alignment: .center) {
//                            Text("\(minPace)")
//                                .font(.system(size: 25,weight: .semibold))
//                            Text("最低")
//                                .font(.system(size:14))
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
                        Spacer()
                        let pace = formatPace(minite: (record?.avaragePace?.doubleValue ?? 0.00))
                        VStack(alignment: .center) {
                            Text("\(pace)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("平均")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        let maxPace = formatPace(minite: (record?.maxPace?.doubleValue ?? 0.00))
                        VStack(alignment: .center) {
                            Text("\(maxPace)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("最高")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    Group{
                        Chart() {
                            ForEach(record?.paceChartData() ?? [], id:\.id) { data in
                                BarMark(x: .value("time", data.time),
                                        y: .value("name", data.name))
                                .foregroundStyle(data.color)
                            }
                        }.frame(height: 200)
                        .chartYAxis(.hidden)
                        
                        VStack(spacing:0) {
                            HStack(spacing:0) {
                                ForEach(record?.paceChartData().reversed() ?? [], id:\.id) { data in
                                    data.color.frame(height: 8)
                                }
                            }.cornerRadius(4)
                            GeometryReader { metrics in
                                HStack(spacing:0) {
                                    Spacer().frame(width:metrics.size.width/10.0).fixedSize()
                                    ForEach(record?.paceChartData().reversed().dropFirst() ?? [], id:\.id) { data in
                                        Text("\(data.name)").font(.system(size:12)).foregroundColor(.gray).frame(width:metrics.size.width/5.0)
                                    }
                                    Spacer().frame(width:metrics.size.width/10.0).fixedSize()
                                }
                            }
                        }
  
                    }
                }.padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 4, y: 4)
                    )
                //心率
                VStack {
                    Text("心率")
                        .font(.system(size:16))
                    HStack(spacing: 16) {
//                        let minHeart = String(format: "%.0f", (record?.minHeart?.doubleValue ?? 0.00))
//                        VStack(alignment: .center) {
//                            Text("\(minHeart)")
//                                .font(.system(size: 25,weight: .semibold))
//                            Text("最低")
//                                .font(.system(size:14))
//                                .foregroundColor(.gray)
//                        }
                        Spacer()
                        
                        let heart = String(format: "%.0f", (record?.avarageHeart?.doubleValue ?? 0.00))
                        VStack(alignment: .center) {
                            Text("\(heart)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("平均")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        let maxHeart = String(format: "%.0f", (record?.maxHeart?.doubleValue ?? 0.00))
                        VStack(alignment: .center) {
                            Text("\(maxHeart)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("最高")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    Group {
                        Chart() {
                            ForEach(record?.heartRateChartData() ?? [], id:\.id) { data in
                                BarMark(x: .value("time", data.time),
                                        y: .value("name", data.name))
                                .foregroundStyle(data.color)
                            }
                        }
                        .frame(height: 180)
                        .chartYAxis(.hidden)
                        VStack(spacing:0) {
                            HStack(spacing:0) {
                                ForEach(record?.heartRateChartData().reversed() ?? [], id:\.id) { data in
                                    data.color.frame(height: 8)
                                }
                            }.cornerRadius(4)
                            GeometryReader { metrics in
                                HStack(spacing:0) {
                                    Spacer().frame(width:metrics.size.width/10.0).fixedSize()
                                    ForEach(record?.heartRateChartData().reversed().dropFirst() ?? [], id:\.id) { data in
                                        Text("\(data.name)").font(.system(size:12)).foregroundColor(.gray).frame(width:metrics.size.width/5.0)
                                    }
                                    Spacer().frame(width:metrics.size.width/10.0).fixedSize()
                                }
                            }
                        }
                    }
                    Divider()
                    HStack {
                        Text("心率区间对应配速").font(.system(size:14))
                        Spacer()
                    }
                    HStack(spacing:10) {
                        VStack(alignment: .center) {
                            Text("<\(record!.heartRate.zone2) :").font(.system(size:14)).foregroundColor(.gray)
                            Text("\(record!.heartRate.zone2)-\(record!.heartRate.zone3) :").font(.system(size:14)).foregroundColor(.gray)
                            Text("\(record!.heartRate.zone3)-\(record!.heartRate.zone4) :").font(.system(size:14)).foregroundColor(.gray)
                            Text("\(record!.heartRate.zone4)-\(record!.heartRate.zone5) :").font(.system(size:14)).foregroundColor(.gray)
                            Text(">\(record!.heartRate.zone5) :").font(.system(size:14)).foregroundColor(.gray)
                        }
                        VStack(alignment: .leading) {
                            if let zonePace = record?.zonePace() {
                                ForEach(zonePace, id:\.id) { pace in
                                    let paceMinite =  pace.paceMinite()
                                    Text("\(formatPace(minite:paceMinite))").font(.system(size:14)).foregroundColor(.black)
                                }
                            }
                        }
                        
                        if let last = lastRecord,
                            let lastZonePace = last.zonePace() {
                            if lastZonePace.count > 0 {
                                VStack(alignment: .leading) {
                                    ForEach(lastZonePace, id:\.id) { pace in
                                        let paceMinite =  pace.paceMinite()
                                        Text("\(formatPace(minite:paceMinite))").font(.system(size:14)).foregroundColor(.gray)
                                    }
                                }
                            }

                        }
                        Spacer()
                    }

                    Spacer(minLength: 10)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 4, y: 4)
                )
                
                //功率
                Group {
                    VStack {
                        Text("功率")
                        Spacer(minLength: 8)
                        HStack(spacing: 16) {
                            let minWatt = String(format: "%.0f", (record?.minWatt?.doubleValue ?? 0.00))
                            VStack(alignment: .center) {
                                Text("\(minWatt)")
                                    .font(.system(size: 25,weight: .semibold))
                                Text("最低")
                                    .font(.system(size:14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            let watt = String(format: "%.0f", (record?.avarageWatt?.doubleValue ?? 0.00))
                            VStack(alignment: .center) {
                                Text("\(watt)")
                                    .font(.system(size: 25,weight: .semibold))
                                Text("平均")
                                    .font(.system(size:14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            let maxWatt = String(format: "%.0f", (record?.maxWatt?.doubleValue ?? 0.00))
                            VStack(alignment: .center) {
                                Text("\(maxWatt)")
                                    .font(.system(size: 25,weight: .semibold))
                                Text("最高")
                                    .font(.system(size:14))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 4, y: 4)
                )
                Spacer(minLength: 10)
            }.padding()
        }
    }
    
}

struct SwiftChart_Previews: PreviewProvider {
    static var previews: some View {
        SwiftChart()
    }
}
