//
//  MonthOfYearLineChart.swift
//  ClimateData
//
//  Created by Bosco Ho on 2024-08-05.
//

import SwiftUI
import Charts

struct MonthOfYearLineChart: ChartContent {
    let localYear: Int
    let dataPoints: [Feature]
    var body: some ChartContent {
        ForEach(dataPoints) { point in
            if let maxTemp = point.properties.maxTemperature {
                LineMark(
                    x: .value("Day", point.properties.localDay),
                    y: .value("Temp.", maxTemp)
                )
                .foregroundStyle(by: .value("Year", point.properties.localYear))
                .interpolationMethod(.monotone)
            }
        }
    }
}
