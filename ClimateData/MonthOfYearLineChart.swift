//
//  MonthOfYearLineChart.swift
//  ClimateData
//
//  Created by Bosco Ho on 2024-08-05.
//

import SwiftUI
import Charts

/// Boxed value to workaround compiler errors with generics and Plottable.
struct AnyPlottable<V: Plottable> {
    let value: V.Type
}

struct MonthOfYearLineChart<
    X: Plottable,
    Y: Plottable,
    F: Plottable
>: ChartContent {
    
    struct PropertiesViewModel {
        let x: PartialKeyPath<Properties>
        let y: PartialKeyPath<Properties>
        let foregroundStyle: PartialKeyPath<Properties>
        let xLabelKey: String
        let yLabelKey: String
        let foregroundStyleLabelKey: String
        init(
            x: (PartialKeyPath<Properties>, String),
            y: (PartialKeyPath<Properties>, String),
            foregroundStyle: (PartialKeyPath<Properties>, String)
        ) {
            self.x = x.0
            self.y = y.0
            self.foregroundStyle = foregroundStyle.0
            self.xLabelKey = x.1
            self.yLabelKey = y.1
            self.foregroundStyleLabelKey = foregroundStyle.1
        }
    }
    
    let dataPoints: [Feature]
    let properties: PropertiesViewModel
    let x: AnyPlottable<X>
    let y: AnyPlottable<Y>
    let foregroundStyle: AnyPlottable<F>
    
    var body: some ChartContent {
        ForEach(dataPoints) { point in
            if let x = point.properties[keyPath: properties.x] as? X,
               let y = point.properties[keyPath: properties.y] as? Y,
               let f = point.properties[keyPath: properties.foregroundStyle] as? F {
                LineMark(
                    x: .value(properties.xLabelKey, x),
                    y: .value(properties.yLabelKey, y)
                )
                .foregroundStyle(by: .value(properties.foregroundStyleLabelKey, f))
                .interpolationMethod(.monotone)
            }
        }
    }
}
