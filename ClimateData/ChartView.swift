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
    var body: some View {
        Chart(features, id: \.hashValue) { feature in
            ForEach(feature) { value in
                if let maxTemp = value.properties.maxTemperature {
                    LineMark(
                        x: .value("Day", value.properties.localDay),
                        y: .value("Temp.", maxTemp)
                    )
                    .foregroundStyle(by: .value("Year", value.properties.localYear))
                    .interpolationMethod(.cardinal)
                }
            }
        }
    }
}

#Preview {
    ChartView(features: [])
}
