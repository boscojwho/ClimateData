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
    let highlightForegroundValue: Double?
    init(
        features: [[Feature]],
        yProperty: PartialKeyPath<Properties>,
        yCodingKey: Properties.CodingKeys,
        yDomain: [Double],
        highlightForegroundValue: Double?
    ) {
        self.features = features
        self.yProperty = yProperty
        self.yCodingKey = yCodingKey
        self.yDomain = yDomain
        self.highlightForegroundValue = highlightForegroundValue
        self.foregroundPlotValues = features
            .compactMap { $0.first?.properties.localYear }
            .sorted()
    }
    
    private let foregroundPlotValues: [Int]
    @State private var selectedIndex: Int?

    var body: some View {
        GroupBox {
            Chart(features, id: \.first?.id) { feature in
                MonthOfYearLineMark(
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
            .chartForegroundStyleScale(domain: yDomain) { (foregroundPlotValue: Double) in
                if let highlightForegroundValue, foregroundPlotValue == highlightForegroundValue {
                    return Color.red
                } else {
                    if let index = foregroundPlotValueIndex(Int(foregroundPlotValue)) {
                        let opacity = Double(index + 1)/Double(foregroundPlotValues.count + 1)
                        return Color.blue.opacity(opacity)
                    } else {
                        return Color.blue.opacity(1)
                    }
                }
            }
        } label: {
            Text("\(yCodingKey.stringValue) in Selected Month (by Year)")
                .font(.largeTitle)
        }
    }
    
    private func foregroundPlotValueIndex(_ value: Int) -> Int? {
        foregroundPlotValues.firstIndex(of: value)
    }
}
