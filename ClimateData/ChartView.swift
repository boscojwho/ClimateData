//
//  ChartView.swift
//  ClimateData
//
//  Created by Bosco Ho on 2024-08-03.
//

import SwiftUI
import Charts

struct ChartView: View {
    let features: [[Feature]]
    let yProperty: PartialKeyPath<Properties>
    let yCodingKey: Properties.CodingKeys
    let yDomain: [Double]
    
    @State private var selectedIndex: Int?

    var body: some View {
        GroupBox {
            Chart(features, id: \.first?.id) { feature in
                MonthOfYearLineChart(
                    dataPoints: feature,
                    properties: .init(
                        x: (\.localDay, "Day"),
                        y: (yProperty, yCodingKey.stringValue),
                        foregroundStyle: (\.localYear, "Year")
                    ),
                    x: .init(value: Int.self),
                    y: .init(value: Double.self),
                    foregroundStyle: .init(value: Int.self)
                )
            }
            .chartLegend(.visible)
            .chartLegend(position: .automatic, alignment: .center, spacing: nil)
            .chartXScale(
                domain: 1...30,
                range: .plotDimension(padding: 20)
            )
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: 1)) { value in
                    if let day = value.as(Int.self) {
                        AxisValueLabel {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                Text("\(day)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                            .frame(width: 24, height: 24)
                        }
                        AxisGridLine(stroke: StrokeStyle(lineCap: .round))
                            .foregroundStyle(Color.gray.opacity(0.1))
                        AxisTick(length: 22, stroke: StrokeStyle(lineCap: .round, dash: [4, 4]))
                    }
                }
            }
            .chartXAxisLabel(alignment: .center) {
                GroupBox {
                    Text("Day of Month")
                        .font(.title2)
                        .fontWeight(.medium)
                }
            }
            .chartYScale(
                domain: yDomain
            )
            .chartYAxis {
                AxisMarks(preset: .extended, position: .leading, values: .stride(by: 5)) { value in
                    if let temp = value.as(Int.self) {
                        AxisValueLabel {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.1))
                                Text("\(temp)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                            .frame(width: 32, height: 22)
                        }
                        AxisGridLine(stroke: StrokeStyle(lineCap: .round, dash: [4, 8]))
                        AxisTick(length: 22, stroke: StrokeStyle(lineCap: .round, dash: [4, 4]))
                    }
                }
            }
            .chartYAxisLabel(position: .top) {
                GroupBox {
                    Text("\(yCodingKey.stringValue)")
                        .font(.title2)
                        .fontWeight(.medium)
                }
            }
            .chartForegroundStyleScale(range: features.enumerated().map {
                offset, element in
//                if offset == 0 {
//                    return Color.red
//                } else {
                    let opacity = Double(offset)/Double(features.count)
                    return Color.blue.opacity(opacity)
//                }
            })
        } label: {
            Text("\(yCodingKey.stringValue) in Selected Month (by Year)")
                .font(.largeTitle)
        }
    }
}
