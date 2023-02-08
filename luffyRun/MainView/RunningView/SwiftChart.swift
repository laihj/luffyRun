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
            Spacer(minLength: 30)
            VStack (spacing: 10){
                HStack(alignment: .center) {
                    let distanceKM = String(format: "%.2f", (record?.distance?.doubleValue ?? 0.00)/1000.0)
                    VStack(alignment: .trailing) {
                        Text("\(distanceKM)")
                            .font(.system(size: 28,weight: .semibold))
                        Text("距离/km")
                            .font(.system(size:14))
                            .foregroundColor(.gray)
                    }
                    Spacer()

                    let kCal = String(format: "%.0f", record?.kCal?.doubleValue ?? 0)
                    VStack(alignment: .trailing) {
                        Text("\(kCal)")
                            .font(.system(size: 28,weight: .semibold))
                        Text("大卡")
                            .font(.system(size:14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    let length = String(format: "%.1f", record?.averageSLength?.doubleValue ?? 0.00)
                    VStack(alignment: .trailing) {
                        Text("\(length)")
                            .font(.system(size: 28,weight: .semibold))
                        Text("平均步长")
                            .font(.system(size:14))
                            .foregroundColor(.gray)
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
                        let minPace = formatPace(minite: (record?.minPace?.doubleValue ?? 0.00))
                        VStack(alignment: .trailing) {
                            Text("\(minPace)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("最低")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        let pace = formatPace(minite: (record?.avaragePace?.doubleValue ?? 0.00))
                        VStack(alignment: .trailing) {
                            Text("\(pace)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("平均")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        let maxPace = formatPace(minite: (record?.maxPace?.doubleValue ?? 0.00))
                        VStack(alignment: .trailing) {
                            Text("\(maxPace)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("最高")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
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
                                ForEach(record?.paceChartData() ?? [], id:\.id) { data in
                                    data.color.frame(height: 8)
                                }
                            }.cornerRadius(4)
                            GeometryReader { metrics in
                                HStack(spacing:0) {
                                    Spacer().frame(width:metrics.size.width/10.0).fixedSize()
                                    ForEach(record?.paceChartData().dropLast() ?? [], id:\.id) { data in
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
                        let minHeart = String(format: "%.0f", (record?.minHeart?.doubleValue ?? 0.00))
                        VStack(alignment: .trailing) {
                            Text("\(minHeart)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("最低")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        let heart = String(format: "%.0f", (record?.avarageHeart?.doubleValue ?? 0.00))
                        VStack(alignment: .trailing) {
                            Text("\(heart)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("平均")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        let maxHeart = String(format: "%.0f", (record?.maxHeart?.doubleValue ?? 0.00))
                        VStack(alignment: .trailing) {
                            Text("\(maxHeart)")
                                .font(.system(size: 25,weight: .semibold))
                            Text("最高")
                                .font(.system(size:14))
                                .foregroundColor(.gray)
                        }
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
                                ForEach(record?.heartRateChartData() ?? [], id:\.id) { data in
                                    data.color.frame(height: 8)
                                }
                            }.cornerRadius(4)
                            GeometryReader { metrics in
                                HStack(spacing:0) {
                                    Spacer().frame(width:metrics.size.width/10.0).fixedSize()
                                    ForEach(record?.heartRateChartData().dropLast() ?? [], id:\.id) { data in
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
                        VStack(alignment: .trailing) {
                            Text("<\(record!.heartRate.zone2) :").font(.system(size:14)).foregroundColor(.gray)
                            Text("\(record!.heartRate.zone2)-\(record!.heartRate.zone3) :").font(.system(size:14)).foregroundColor(.gray)
                            Text("\(record!.heartRate.zone3)-\(record!.heartRate.zone4) :").font(.system(size:14)).foregroundColor(.gray)
                            Text("\(record!.heartRate.zone4)-\(record!.heartRate.zone5) :").font(.system(size:14)).foregroundColor(.gray)
                            Text(">\(record!.heartRate.zone5) :").font(.system(size:14)).foregroundColor(.gray)
                        }
                        VStack(alignment: .leading) {
                            let zonePace = record?.zonePace()
                            let zone1pace = zonePace?[Zone.zone1]?.paceMinite() ?? 0.0
                            Text("\(formatPace(minite:zone1pace))").font(.system(size:14)).foregroundColor(.black)
                            let zone2pace = zonePace?[Zone.zone2]?.paceMinite() ?? 0.0
                            Text("\(formatPace(minite:zone2pace))").font(.system(size:14)).foregroundColor(.black)
                            let zone3pace = zonePace?[Zone.zone3]?.paceMinite() ?? 0.0
                            Text("\(formatPace(minite:zone3pace))").font(.system(size:14)).foregroundColor(.black)
                            let zone4pace = zonePace?[Zone.zone4]?.paceMinite() ?? 0.0
                            Text("\(formatPace(minite:zone4pace))").font(.system(size:14)).foregroundColor(.black)
                            let zone5pace = zonePace?[Zone.zone5]?.paceMinite() ?? 0.0
                            Text("\(formatPace(minite:zone5pace))").font(.system(size:14)).foregroundColor(.black)
                        }
                        
                        if let last = lastRecord,
                            let lastZonePace = last.zonePace() {
                            VStack(alignment: .leading) {

                                let zone1pace = lastZonePace[Zone.zone1]?.paceMinite() ?? 0.0
                                Text("\(formatPace(minite:zone1pace))").font(.system(size:14)).foregroundColor(.gray)
                                let zone2pace = lastZonePace[Zone.zone2]?.paceMinite() ?? 0.0
                                Text("\(formatPace(minite:zone2pace))").font(.system(size:14)).foregroundColor(.gray)
                                let zone3pace = lastZonePace[Zone.zone3]?.paceMinite() ?? 0.0
                                Text("\(formatPace(minite:zone3pace))").font(.system(size:14)).foregroundColor(.gray)
                                let zone4pace = lastZonePace[Zone.zone4]?.paceMinite() ?? 0.0
                                Text("\(formatPace(minite:zone4pace))").font(.system(size:14)).foregroundColor(.gray)
                                let zone5pace = lastZonePace[Zone.zone5]?.paceMinite() ?? 0.0
                                Text("\(formatPace(minite:zone5pace))").font(.system(size:14)).foregroundColor(.gray)
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
                            VStack(alignment: .trailing) {
                                Text("\(minWatt)")
                                    .font(.system(size: 25,weight: .semibold))
                                Text("最低")
                                    .font(.system(size:14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            let watt = String(format: "%.0f", (record?.avarageWatt?.doubleValue ?? 0.00))
                            VStack(alignment: .trailing) {
                                Text("\(watt)")
                                    .font(.system(size: 25,weight: .semibold))
                                Text("平均")
                                    .font(.system(size:14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            let maxWatt = String(format: "%.0f", (record?.maxWatt?.doubleValue ?? 0.00))
                            VStack(alignment: .trailing) {
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
