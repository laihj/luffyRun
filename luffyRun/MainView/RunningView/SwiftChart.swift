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
                        }.frame(height: 180)
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
                                        Text("5'56''").font(.system(size:12)).foregroundColor(.gray).frame(width:metrics.size.width/5.0)
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
                    Chart() {
                        ForEach(record?.heartRateChartData() ?? [], id:\.id) { data in
                            BarMark(x: .value("time", data.time),
                                    y: .value("name", data.name))
                            .foregroundStyle(data.color)
                        }
                    }
                    .frame(height: 240)
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
